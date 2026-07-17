namespace Proiect.DTOs
{
    public class RecipeCreateDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string Instruction { get; set; }
        public string ImageUrl { get; set; }
        public string MealType { get; set; }
        public int CookingTime { get; set; }
        public int Rating { get; set; }
        public string QuickEasy { get; set; }
        public string Allergens { get; set; }


        public List<IngredientQuantityDto> Ingredients { get; set; }
    }
}

