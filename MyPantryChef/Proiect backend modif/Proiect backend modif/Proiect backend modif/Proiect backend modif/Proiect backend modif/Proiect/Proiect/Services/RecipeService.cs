using Microsoft.EntityFrameworkCore;
using Proiect.Models;
using Proiect.Data;

namespace Proiect.Services
{
    public class RecipeService : IRecipeService
    {
        private readonly AppDbContext _context;


        public RecipeService(AppDbContext context)
        {
            _context = context;
        }


        public async Task<List<Recipe>> GetAllAsync()
        {
            return await _context.Set<Recipe>().ToListAsync();
        }


        public async Task<List<Recipe>> GetRecommendedAsync()
        {
            return await _context.Recipes
                .OrderByDescending(r => r.Rating)
                .Take(3)
                .ToListAsync();
        }


        public async Task<List<Recipe>> SearchAsync(string query, string type, string quickAndEasy, string timeToMake, List<string> allergens)
        {
            var result = _context.Recipes
                .Include(r => r.RecipeIngredients)
                    .ThenInclude(ri => ri.Ingredient)
                .AsQueryable();

            if (!string.IsNullOrEmpty(query))
                result = result.Where(r => r.Title.Contains(query));

            if (!string.IsNullOrEmpty(type))
                result = result.Where(r => r.MealType == type);

            if (!string.IsNullOrEmpty(timeToMake))
            {
                if (timeToMake == "more than 1 hour")
                {
                    result = result.Where(r => r.CookingTime > 60);
                }
                else
                {
                    var cleaned = timeToMake.Replace(" minutes or less", "").Replace(" hour or less", "60").Trim();

                    if (int.TryParse(cleaned, out int maxTime))
                    {
                        result = result.Where(r => r.CookingTime <= maxTime);
                    }
                }
            }

            if (!string.IsNullOrEmpty(quickAndEasy))
            {
                result = result.Where(r => r.QuickEasy != null && r.QuickEasy.Contains(quickAndEasy));
            }


            if (allergens != null && allergens.Any())
            {
                foreach (var allergen in allergens)
                {
                    result = result.Where(r => r.Allergens == null || !r.Allergens.Contains(allergen));
                }
            }

            return await result.ToListAsync();
        }
    }
}