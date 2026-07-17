using Microsoft.AspNetCore.Mvc;
using Proiect.Services;
using Proiect.Data;
using Proiect.Models;
using Proiect.DTOs;
using Microsoft.EntityFrameworkCore;
using Proiect.ViewModels;
using System.Diagnostics;
using Proiect_InterfataLogare.Models;
using Proiect_InterfataLogare.DTOs;

namespace Proiect.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RecipeController : ControllerBase
    {
        private readonly IRecipeService _service;
        private readonly AppDbContext _context;
        private readonly EmailService _emailService;

        public RecipeController(IRecipeService service, AppDbContext context, EmailService emailService) 
        {
            _service = service;
            _context = context;
            _emailService = emailService;
        }


        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var recipes = await _service.GetAllAsync();
            return Ok(recipes);
        }


        [HttpGet("recommended")]
        public async Task<IActionResult> GetRecommended()
        {
            var recommended = await _service.GetRecommendedAsync();
            return Ok(recommended);
        }


        [HttpPost("create")]
        public async Task<IActionResult> CreateRecipe([FromBody] RecipeCreateDto dto)
        {
            var exists = await _context.Recipes.AnyAsync(r =>
                r.Title.ToLower().Trim() == dto.Title.ToLower().Trim()
            );

            if (exists)
                return BadRequest(new { message = "A recipe with this title already exists." });

            var recipe = new Recipe
            {
                Title = dto.Title,
                Description = dto.Description,
                Instruction = dto.Instruction,
                ImageUrl = dto.ImageUrl,
                MealType = dto.MealType,
                CookingTime = dto.CookingTime,
                QuickEasy = dto.QuickEasy,       
                Allergens = dto.Allergens       
            };

            _context.Recipes.Add(recipe);
            await _context.SaveChangesAsync();

            foreach (var ing in dto.Ingredients)
            {
                var recipeIngredient = new RecipeIngredient
                {
                    RecipeId = recipe.Id,
                    IngredientId = ing.IngredientId
                };
                _context.RecipeIngredients.Add(recipeIngredient);
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "The recipe was successfully created!" });

        }


        [HttpPost("generate")]
        public async Task<IActionResult> GenerateRecipes([FromBody] List<IngredientQuantityDto> selectedIngredients)
        {
            try
            {
                if (selectedIngredients == null || !selectedIngredients.Any())
                    return BadRequest("Ingredient list is empty.");

                var selectedIds = selectedIngredients
                    .Select(i => i.IngredientId)
                    .Distinct()
                    .ToList();

                Debug.WriteLine("SelectedIds: " + string.Join(", ", selectedIds));

                var recipes = await _context.Recipes
                    .Include(r => r.RecipeIngredients)
                        .ThenInclude(ri => ri.Ingredient)
                    .Where(r => r.RecipeIngredients.Any(ri => selectedIds.Contains(ri.IngredientId)))
                    .ToListAsync();

                var result = recipes.Select(r => new RecipeSimpleDto
                {
                    Id = r.Id,
                    Title = r.Title,
                    ImageUrl = r.ImageUrl,
                    CookingTime = r.CookingTime,
                    MealType = r.MealType, 
                    Ingredients = r.RecipeIngredients
                    .Select(ri => ri.Ingredient.Name)
                    .ToList()
                            }).ToList();


                return Ok(result);
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Error in GenerateRecipes: " + ex.Message);
                return StatusCode(500, "Internal server error: " + ex.Message);
            }
        }


        [HttpGet("{id}")]
        public async Task<ActionResult<RecipeViewModel>> GetRecipe(int id)
        {
            var recipe = await _context.Recipes
                .Include(r => r.RecipeIngredients)
                    .ThenInclude(ri => ri.Ingredient)
                .Include(r => r.Comments)
                    .ThenInclude(c => c.User)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (recipe == null)
                return NotFound();

            // calc media si nr voturi
            var ratings = await _context.Ratings
                .Where(r => r.RecipeId == recipe.Id)
                .ToListAsync();

            double averageRating = ratings.Any() ? ratings.Average(r => r.Value) : 0;
            int ratingCount = ratings.Count;

            var viewModel = new RecipeViewModel
            {
                Id = recipe.Id,
                Title = recipe.Title,
                CookingTime = recipe.CookingTime,
                Rating = averageRating, 
                Description = recipe.Description,
                Instructions = recipe.Instruction,
                ImageUrl = recipe.ImageUrl,
                MealType = recipe.MealType,
                RatingCount = ratingCount, 
                Ingredients = recipe.RecipeIngredients.Select(ri => new IngredientViewModel
                {
                    Id = ri.IngredientId,
                    Name = ri.Ingredient.Name
                }).ToList(),
                Comments = recipe.Comments.Select(c => new CommentViewModel
                {
                    Id = c.Id, 
                    Username = c.User.Username,
                    Description = c.Description,
                    Date = c.Data_Comment
                }).ToList()
            };

            return Ok(viewModel);
        }






        [HttpPost("{id}/comment")]
        public async Task<IActionResult> AddComment(int id, [FromBody] CommentCreateDto dto)
        {
            var recipe = await _context.Recipes.FindAsync(id);
            var user = await _context.Users.FindAsync(dto.Id_User);

            if (recipe == null || user == null)
            {
                return NotFound(new { message = "The recipe or user does not exist." });
            }

            
            if (string.IsNullOrWhiteSpace(dto.Description) || dto.Description.Length > 500)
            {
                return BadRequest(new { message = "Comment must be between 1 and 500 characters." });
            }

            var comment = new Comment
            {
                Id_Recipe = id,
                Id_User = dto.Id_User,
                Description = dto.Description,
                Data_Comment = DateTime.Now
            };

            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            return Ok(new { message = "The comment was added successfully!" });
        }

        [HttpPost("{id}/rate")]
        public async Task<IActionResult> RateRecipe(int id, [FromBody] RateDto dto)
        {
            var recipe = await _context.Recipes.FindAsync(id);
            if (recipe == null)
                return NotFound("Recipe not found");

            var existingRating = await _context.Ratings
                .FirstOrDefaultAsync(r => r.RecipeId == id && r.UserId == dto.UserId);

            if (existingRating != null)
            {
                existingRating.Value = dto.Value;
            }
            else
            {
                _context.Ratings.Add(new Rating
                {
                    RecipeId = id,
                    UserId = dto.UserId,
                    Value = dto.Value
                });
            }

            await _context.SaveChangesAsync();

            // Recalc media
            var average = await _context.Ratings
                .Where(r => r.RecipeId == id)
                .AverageAsync(r => r.Value);

            recipe.Rating = (int)Math.Round(average);
            await _context.SaveChangesAsync();

            return Ok(average);
        }








        [HttpPost("search-by-title")]
        public IActionResult SearchByTitle([FromBody] RecipeSearchModel filters)
        {
            if (filters == null || string.IsNullOrWhiteSpace(filters.Query))
                return BadRequest("Query is required.");

            var recipes = _context.Recipes
                .Where(r => !string.IsNullOrWhiteSpace(r.Title) &&
                            r.Title.ToLower().Contains(filters.Query.ToLower()))
                .ToList();

            return Ok(recipes);
        }


        [HttpPost("search")]
        public IActionResult FilterRecipes([FromBody] RecipeFilterModel filters)
        {
            var query = _context.Recipes.AsQueryable();

            if (!string.IsNullOrWhiteSpace(filters.Query))
            {
                query = query.Where(r =>
                    !string.IsNullOrWhiteSpace(r.Title) &&
                    r.Title.ToLower().Contains(filters.Query.ToLower())
                );
            }

            if (!string.IsNullOrWhiteSpace(filters.Type))
            {
                query = query.Where(r =>
                    !string.IsNullOrWhiteSpace(r.MealType) &&
                    r.MealType.ToLower() == filters.Type.ToLower()
                );
            }

            if (!string.IsNullOrWhiteSpace(filters.QuickAndEasy))
            {
                query = query.Where(r =>
                    !string.IsNullOrWhiteSpace(r.QuickEasy) &&
                    r.QuickEasy.ToLower().Contains(filters.QuickAndEasy.ToLower())
                );
            }

            if (!string.IsNullOrWhiteSpace(filters.TimeToMake))
            {
                switch (filters.TimeToMake.ToLower())
                {
                    case "10 minutes or less":
                        query = query.Where(r => r.CookingTime <= 10); break;
                    case "20 minutes or less":
                        query = query.Where(r => r.CookingTime <= 20 && r.CookingTime > 10); break;
                    case "30 minutes or less":
                        query = query.Where(r => r.CookingTime <= 30 && r.CookingTime > 20); break;
                    case "45 minutes or less":
                        query = query.Where(r => r.CookingTime <= 45 && r.CookingTime > 30); break;
                    case "1 hour or less":
                        query = query.Where(r => r.CookingTime <= 60 && r.CookingTime > 45); break;
                    case "more than 1 hour":
                        query = query.Where(r => r.CookingTime > 60); break;
                }
            }

            // excludem retete dupa alergeni
            if (filters.Allergens != null && filters.Allergens.Count > 0)
            {
                var allergensList = filters.Allergens
                    .Select(a => a.Trim().ToLower())
                    .ToList();

                query = query
                    .AsEnumerable()
                    .Where(r =>
                        string.IsNullOrWhiteSpace(r.Allergens) || // le pastram daca nu au alergeni
                        !r.Allergens
                            .Split(',', StringSplitOptions.RemoveEmptyEntries)
                            .Select(a => a.Trim().ToLower())
                            .Any(a => allergensList.Contains(a)) // exclud daca are vreun alergen
                    )
                    .AsQueryable();
            }

            return Ok(query.ToList());
        }



        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRecipe(int id)
        {
            try
            {
                var recipe = await _context.Recipes
                    .Include(r => r.RecipeIngredients)
                        .ThenInclude(ri => ri.Ingredient)
                    .FirstOrDefaultAsync(r => r.Id == id);

                if (recipe == null)
                    return NotFound(new { message = "Recipe not found." });

                recipe.RecipeIngredients = recipe.RecipeIngredients
                    .Where(ri => ri != null && ri.IngredientId != 0)
                    .ToList();

                _context.RecipeIngredients.RemoveRange(recipe.RecipeIngredients);
                _context.Recipes.Remove(recipe);
                await _context.SaveChangesAsync();

                return Ok(new { message = "The recipe was successfully deleted." });
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error DeleteRecipe: " + ex);
                return StatusCode(500, $"Internal error while deleting recipe: {ex.Message}");
            }
        }


        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRecipe(int id, [FromBody] RecipeCreateDto dto)
        {
            var recipe = await _context.Recipes
                .Include(r => r.RecipeIngredients)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (recipe == null)
                return NotFound();

            recipe.Title = dto.Title;
            recipe.Description = dto.Description;
            recipe.Instruction = dto.Instruction;
            recipe.ImageUrl = dto.ImageUrl;
            recipe.MealType = dto.MealType;
            recipe.CookingTime = dto.CookingTime;
            recipe.Rating = dto.Rating;
            recipe.QuickEasy = dto.QuickEasy;
            recipe.Allergens = dto.Allergens;

            _context.RecipeIngredients.RemoveRange(recipe.RecipeIngredients);

            foreach (var ing in dto.Ingredients)
            {
                _context.RecipeIngredients.Add(new RecipeIngredient
                {
                    RecipeId = recipe.Id,
                    IngredientId = ing.IngredientId
                });
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Recipe updated successfully!" });
        }

        [HttpPost("generate-with-filters")]
        public async Task<IActionResult> GenerateRecipesWithFilters([FromBody] GenerateWithFiltersDto input)
        {
            if (input.Ingredients == null || !input.Ingredients.Any())
                return BadRequest("Ingredient list is empty.");

            var selectedIds = input.Ingredients
                .Select(i => i.IngredientId)
                .Distinct()
                .ToList();

            var query = _context.Recipes
                .Include(r => r.RecipeIngredients)
                .ThenInclude(ri => ri.Ingredient)
                .Where(r => r.RecipeIngredients.Any(ri => selectedIds.Contains(ri.IngredientId)))
                .AsQueryable();

           

            if (!string.IsNullOrWhiteSpace(input.Filters?.Type))
                query = query.Where(r => r.MealType.ToLower() == input.Filters.Type.ToLower());

            if (!string.IsNullOrWhiteSpace(input.Filters?.QuickAndEasy))
                query = query.Where(r => r.QuickEasy.ToLower().Contains(input.Filters.QuickAndEasy.ToLower()));

            if (!string.IsNullOrWhiteSpace(input.Filters?.TimeToMake))
            {
                switch (input.Filters.TimeToMake.ToLower())
                {
                    case "10 minutes or less": query = query.Where(r => r.CookingTime <= 10); break;
                    case "20 minutes or less": query = query.Where(r => r.CookingTime <= 20 && r.CookingTime > 10); break;
                    case "30 minutes or less": query = query.Where(r => r.CookingTime <= 30 && r.CookingTime > 20); break;
                    case "45 minutes or less": query = query.Where(r => r.CookingTime <= 45 && r.CookingTime > 30); break;
                    case "1 hour or less": query = query.Where(r => r.CookingTime <= 60 && r.CookingTime > 45); break;
                    case "more than 1 hour": query = query.Where(r => r.CookingTime > 60); break;
                }
            }

            // exclud care au alergeni selctati
            if (input.Filters?.Allergens != null && input.Filters.Allergens.Any())
            {
                var allergensList = input.Filters.Allergens
                    .Select(a => a.Trim().ToLower())
                    .ToList();

                query = query
                    .AsEnumerable()
                    .Where(r =>
                        string.IsNullOrWhiteSpace(r.Allergens) || // pastrez reteta fara alergeni
                        !r.Allergens
                            .Split(',', StringSplitOptions.RemoveEmptyEntries)
                            .Select(a => a.Trim().ToLower())
                            .Any(a => allergensList.Contains(a)) // exclud daca are vreun alergen selectat
                    )
                    .AsQueryable();
            }

            var result = query.ToList().Select(r => new RecipeSimpleDto
            {
                Id = r.Id,
                Title = r.Title,
                ImageUrl = r.ImageUrl,
                CookingTime = r.CookingTime,
                MealType = r.MealType,
                Ingredients = r.RecipeIngredients.Select(ri => ri.Ingredient.Name).ToList()
            }).ToList();

            return Ok(result);
        }

        [HttpPost("send-cart-summary")]
        public async Task<IActionResult> SendCartSummary([FromBody] CartEmailDto cart)
        {
            var user = await _context.Users.FindAsync(cart.UserId);
            if (user == null || string.IsNullOrWhiteSpace(user.Email))
            {
                return BadRequest("User or email not found.");
            }

            var itemList = string.Join("\n", cart.Items.Select(i => $"- Ingredient #{i.IngredientId}: {i.Quantity} pcs"));

            var body = $"Hello {user.Username},\n\nHere's your cart summary:\n{itemList}\n\nBest,\nMyPantryChef 🍽️";

            try
            {
                await _emailService.SendEmailAsync(user.Email, "Your Cart Summary 🛒", body);
                return Ok("Cart summary sent successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error sending cart email: " + ex.Message);
                return StatusCode(500, "Email failed to send.");
            }
        }


        [HttpDelete("comment/{commentId}")]
        public async Task<IActionResult> DeleteComment(int commentId)
        {
            var comment = await _context.Comments.FindAsync(commentId);
            if (comment == null)
                return NotFound("Comment not found.");

            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Comment deleted successfully!" });
        }

        [HttpPut("comment/{commentId}")]
        public async Task<IActionResult> UpdateComment(int commentId, [FromBody] CommentCreateDto dto)
        {
            var comment = await _context.Comments.FindAsync(commentId);
            if (comment == null)
                return NotFound("Comment not found.");

            comment.Description = dto.Description;
            comment.Data_Comment = DateTime.Now;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Comment updated successfully!" });
        }



    }

}



