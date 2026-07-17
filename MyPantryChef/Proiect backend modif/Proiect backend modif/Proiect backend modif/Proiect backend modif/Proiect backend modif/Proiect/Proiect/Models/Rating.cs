using Proiect.Models;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace Proiect_InterfataLogare.Models
{
    [Table("Rating")]
    public class Rating
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("id_user")]
        public int UserId { get; set; }

        [Column("id_recipe")]
        public int RecipeId { get; set; }

        [Column("value")]
        [Range(1, 5)]
        public int Value { get; set; }

        public User User { get; set; }
        public Recipe Recipe { get; set; }
    }
}
