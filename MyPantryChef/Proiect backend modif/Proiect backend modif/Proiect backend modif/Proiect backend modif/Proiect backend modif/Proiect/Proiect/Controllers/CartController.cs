using Microsoft.AspNetCore.Mvc;
using Proiect.Data;
using Proiect.DTOs;
using Microsoft.EntityFrameworkCore;
using Proiect.Services;
using Proiect_InterfataLogare.DTOs;
using Proiect_InterfataLogare.Models;

namespace Proiect.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CartController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly EmailService _emailService;
        private static List<IngredientQuantityDto> ShoppingCart = new();

        public CartController(AppDbContext context, EmailService emailService)
        {
            _context = context;
            _emailService = emailService;
        }


        [HttpGet]
        public IActionResult GetCart()
        {
            return Ok(ShoppingCart);
        }


        [HttpPost("add")]
        public IActionResult AddToCart([FromBody] IngredientQuantityDto ingredient)
        {
            var existing = ShoppingCart.FirstOrDefault(i => i.IngredientId == ingredient.IngredientId);
            if (existing != null)
            {
                existing.Quantity += ingredient.Quantity;
            }
            else
            {
                ShoppingCart.Add(ingredient);
            }

            return Ok(ShoppingCart);
        }


        [HttpDelete("remove/{ingredientId}")]
        public IActionResult RemoveFromCart(int ingredientId)
        {
            var item = ShoppingCart.FirstOrDefault(i => i.IngredientId == ingredientId);
            if (item != null)
            {
                ShoppingCart.Remove(item);
            }

            return Ok(ShoppingCart);
        }


        [HttpDelete("clear")]
        public IActionResult ClearCart()
        {
            ShoppingCart.Clear();
            return Ok(new { message = "The cart has been emptied." });
        }


        [HttpPost("generate-recipes")]
        public async Task<IActionResult> GenerateRecipes([FromBody] List<IngredientQuantityDto> selectedIngredients)
        {
            var selectedIds = selectedIngredients.Select(i => i.IngredientId).ToList();

            var recipes = await _context.Recipes
                .Include(r => r.RecipeIngredients)
                    .ThenInclude(ri => ri.Ingredient)
                .Where(r => r.RecipeIngredients.All(ri => selectedIds.Contains(ri.IngredientId)))
                .ToListAsync();

            return Ok(recipes);
        }


        [HttpPost("send-cart-summary")]
        public async Task<IActionResult> SendCartByEmail([FromBody] CartEmailDto request)
        {
            if (request == null || request.Items == null || !request.Items.Any())
                return BadRequest("The cart is empty.");

            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null || string.IsNullOrWhiteSpace(user.Email))
                return BadRequest("The user does not have an associated email.");

            var existing = _context.ProductToBuy.Where(p => p.Id_User == request.UserId);
            _context.ProductToBuy.RemoveRange(existing);

            foreach (var item in request.Items)
            {
                _context.ProductToBuy.Add(new ProductToBuy
                {
                    Id_User = request.UserId,
                    Id_Ingredient = item.IngredientId,
                    Quantity = (int)item.Quantity,
                    Is_Checked = false
                });
            }

            await _context.SaveChangesAsync();

            var ingredientDict = await _context.Ingredients
                .ToDictionaryAsync(i => i.Id, i => i.Name);

            var lines = request.Items
                .Select(item => $"{ingredientDict[item.IngredientId]} – {item.Quantity} pcs")
                .ToList();

            string message = "Your cart:\n" + string.Join("\n", lines);

            try
            {
                await _emailService.SendEmailAsync(user.Email, "Shopping cart", message);
                return Ok("Email sent successfully and cart saved!");
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ Error sending email: " + ex.Message);
                return StatusCode(500, "Email failed to send.");
            }
        }

    }
}
