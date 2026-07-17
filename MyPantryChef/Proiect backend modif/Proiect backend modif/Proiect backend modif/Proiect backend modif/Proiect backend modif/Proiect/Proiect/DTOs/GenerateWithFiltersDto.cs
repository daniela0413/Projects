using Proiect.DTOs;
using Proiect.ViewModels;

namespace Proiect_InterfataLogare.DTOs
{
    public class GenerateWithFiltersDto
    {
        public List<IngredientQuantityDto> Ingredients { get; set; }
        public RecipeFilterModel Filters { get; set; }
    }
}
