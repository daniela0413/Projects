using System.ComponentModel.DataAnnotations.Schema;

namespace Proiect.Models
{
    [Table ("Recipe_ingredients")]
    public class RecipeIngredient
    {
        [Column("id_recipe", Order =0)]
        public int RecipeId { get; set; }

        [ForeignKey("RecipeId")]
        public Recipe Recipe { get; set; }

        [Column("id_ingredient", Order=1)]
        public int IngredientId { get; set; }

        [ForeignKey("IngredientId")]
        public Ingredient Ingredient { get; set; }
    }
}
