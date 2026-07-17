using Microsoft.AspNetCore.Mvc;
using Proiect.Data;
using Proiect.Models;
namespace Proiect.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FilterOptionsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FilterOptionsController(AppDbContext context)
        {
            _context = context;
        }


        [HttpGet("mealtypes")]
        public IActionResult GetMealTypes()
        {
            var types = _context.Recipes
                .Select(r => r.MealType)
                .Distinct()
                .ToList();

            return Ok(types);
        }


        [HttpGet("cookingtimes")]
        public IActionResult GetCookingTimes()
        {
            var predefinedTimes = new List<string>
            {
                "10 minutes or less",
                "20 minutes or less",
                "30 minutes or less",
                "45 minutes or less",
                "1 hour or less",
                "more than 1 hour"
            };

            return Ok(predefinedTimes);
        }


        [HttpGet("quickeasy")]
        public IActionResult GetQuickEasyOptions()
        {
            var quick = _context.Recipes
                .Where(r => r.QuickEasy != null && r.QuickEasy.Trim() != "")
                .AsEnumerable()
                .SelectMany(r => r.QuickEasy
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                .Distinct()
                .ToList();

            return Ok(quick);
        }


        [HttpGet("allergens")]
        public IActionResult GetAllergens()
        {
            var allergens = _context.Recipes
                .AsEnumerable()
                .SelectMany(r => r.Allergens
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                .Distinct()
                .ToList();

            return Ok(allergens);
        }
    }
}