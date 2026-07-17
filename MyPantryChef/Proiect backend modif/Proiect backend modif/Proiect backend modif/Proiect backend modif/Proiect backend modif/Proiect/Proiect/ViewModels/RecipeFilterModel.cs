namespace Proiect.ViewModels
{
    public class RecipeFilterModel
    {
        public string Query { get; set; }
        public string Type { get; set; }
        public string QuickAndEasy { get; set; }
        public string TimeToMake { get; set; }
        public List<string> Allergens { get; set; }
    }
}