using System.ComponentModel.DataAnnotations.Schema;

namespace Back_end3.Models
{
    [Table("Category")]
    public class Category
    {
        public int Id { get; set; }

        [Column("name")]
        public string Name { get; set; }

        [Column("imageUrl")]  
        public string ImageUrl { get; set; }
    }
}
