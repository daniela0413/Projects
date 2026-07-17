using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Proiect.Models
{
    [Table( "Ingredients") ]
    public class Ingredient
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }
        [Column("name")]
        public string Name { get; set; }

        [Column("id_category")]
        public int CategoryId {  get; set; }

        public ICollection<RecipeIngredient> RecipeIngredients { get; set; }
    }
}
