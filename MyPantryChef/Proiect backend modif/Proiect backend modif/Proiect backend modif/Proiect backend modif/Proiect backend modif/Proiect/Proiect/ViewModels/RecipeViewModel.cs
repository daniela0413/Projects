namespace Proiect.ViewModels
{
    public class RecipeViewModel
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public int CookingTime { get; set; }
        public double Rating { get; set; }
        public string Description { get; set; }
        public string Instructions { get; set; }
        public string ImageUrl { get; set; }
        public string MealType { get; set; }
        public int RatingCount { get; set; }

        public List<IngredientViewModel> Ingredients { get; set; }
        public List<CommentViewModel> Comments { get; set; }
    }
}
