using Back_end3.Models;
using Microsoft.AspNetCore.Mvc;
using Proiect.Data;
using Proiect.DTOs;

namespace Proiect.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CategoriesController(AppDbContext context)
        {
            _context = context;
        }


        [HttpGet]
        public IActionResult GetCategories()
        {
            var categories = _context.Categories
                .Select(c => new
                {
                    c.Id,
                    c.Name,
                    c.ImageUrl  
                })
                .ToList();

            return Ok(categories);
        }


        [HttpPost("create")]
        public async Task<IActionResult> AddCategory([FromBody] CategoryCreateDto dto)
        {
            
            if (string.IsNullOrWhiteSpace(dto.Name))
                return BadRequest("The category name is required.");

            
            if (string.IsNullOrWhiteSpace(dto.ImageUrl))
                return BadRequest("The image URL is required.");

           
            var exists = _context.Categories
                .Any(c => c.Name.Trim().ToLower() == dto.Name.Trim().ToLower());

            if (exists)
                return BadRequest("This category already exists.");

           
            var category = new Category
            {
                Name = dto.Name.Trim(),
                ImageUrl = dto.ImageUrl
            };
            
            _context.Categories.Add(category);
            await _context.SaveChangesAsync();

            return Ok(category);
        }


        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}