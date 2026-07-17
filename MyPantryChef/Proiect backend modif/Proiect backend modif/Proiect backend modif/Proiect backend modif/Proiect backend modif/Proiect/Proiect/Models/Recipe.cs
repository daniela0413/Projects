using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Proiect.Models
{
    [Table ("Recipe")]
    public class Recipe
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }
        [Column("title")]
        public string Title { get; set; }
        [Column("description")]
        public string Description { get; set; }

        [Column("instructions")]
        public string Instruction { get; set; }

        [Column("image_url")]
        public string ImageUrl { get; set; }

        [Column ("meal_type")]
        public string MealType { get; set; }

        [Column ("cooking_time")]
        public int CookingTime { get; set; }

        [Column("rating")]
        public int Rating { get; set; }

        [Column("quick_easy")]
        public string QuickEasy { get; set; }

        [Column("allergens")]
        public string Allergens { get; set; }


        public ICollection<RecipeIngredient> RecipeIngredients { get; set; }
        public ICollection<Comment> Comments { get; set; }
    }
}
