using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Proiect.Models
{
    [Table("Comment")]
    public class Comment
    {

        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("id_recipe")]
        public int Id_Recipe { get; set; }

        [ForeignKey("Id_Recipe")]
        public Recipe Recipe { get; set; }

        [Column("id_user")]
        public int Id_User { get; set; }
        [ForeignKey("Id_User")]
        public User User { get; set; }

        [Column ("data_c")]
        public DateTime Data_Comment { get; set; }

        [Column("description")]
        public string Description { get; set; }
    }
}
