namespace Proiect_InterfataLogare.Models
{
    public class ProductToBuy
    {
        public int Id { get; set; }
        public int Id_User { get; set; }
        public int Id_Ingredient { get; set; }
        public bool Is_Checked { get; set; } = false;
        public int Quantity { get; set; }
    }
}
