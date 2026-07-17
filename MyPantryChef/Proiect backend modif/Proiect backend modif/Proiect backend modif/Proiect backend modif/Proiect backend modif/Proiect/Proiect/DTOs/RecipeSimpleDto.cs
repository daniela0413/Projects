namespace Proiect.DTOs
{
    public class RecipeSimpleDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string ImageUrl { get; set; }
        public int CookingTime { get; set; }
        public List<string> Ingredients { get; set; }

        public string MealType { get; set; } 
    }

}
