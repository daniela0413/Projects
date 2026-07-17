using Proiect.DTOs;

namespace Proiect_InterfataLogare.DTOs
{
    public class CartEmailDto
    {
        public int UserId { get; set; }
        public List<IngredientQuantityDto> Items { get; set; }
    }
}

