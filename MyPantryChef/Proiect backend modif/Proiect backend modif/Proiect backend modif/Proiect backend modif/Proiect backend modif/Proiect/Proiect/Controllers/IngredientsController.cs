using Microsoft.AspNetCore.Mvc;
using Proiect.Data;
using Proiect.DTOs;
using Proiect.Models;

namespace Proiect.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class IngredientsController : ControllerBase
    {

        private readonly AppDbContext _context;

        public IngredientsController(AppDbContext context)
        {
            _context = context;
        }


        [HttpGet("by-category/{categoryId}")]
        public IActionResult GetByCategory(int categoryId)
        {
            var ingredients = _context.Ingredients
                .Where(i => i.CategoryId == categoryId)
                .Select(i => new { i.Id, i.Name })
                .ToList();

            return Ok(ingredients);
        }


        [HttpGet]
        public IActionResult GetAllIngredients()
        {
            var ingredients = _context.Ingredients.ToList();

            return Ok(ingredients);
        }


        [HttpPost("create")]
        public async Task<IActionResult> AddIngredient([FromBody] IngredientCreateDto dto)
        {
            bool exists = _context.Ingredients
                .Any(i => i.Name.ToLower().Trim() == dto.Name.ToLower().Trim() && i.CategoryId == dto.CategoryId);

            if (exists)
            {
                return BadRequest(new { message = "The ingredient already exists." });
            }
            var ingredient = new Ingredient
            {
                Name = dto.Name.Trim(),
                CategoryId = dto.CategoryId
            };
            _context.Ingredients.Add(ingredient);
            await _context.SaveChangesAsync();

            return Ok(ingredient);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteIngredient(int id)
        {
            var ingredient = await _context.Ingredients.FindAsync(id);
            if (ingredient == null) return NotFound();

            _context.Ingredients.Remove(ingredient);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }

}
