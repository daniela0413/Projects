using Proiect.Models;

namespace Proiect.Services
{
    public interface IRecipeService
    {
        Task<List<Recipe>> GetAllAsync();
        Task<List<Recipe>> GetRecommendedAsync();
        Task<List<Recipe>> SearchAsync(string query, string type, string quickAndEasy, string timeToMake, List<string> allergens);
    }
}
