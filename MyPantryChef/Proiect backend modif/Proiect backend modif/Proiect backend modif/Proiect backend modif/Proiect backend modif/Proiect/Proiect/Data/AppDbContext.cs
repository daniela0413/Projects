using Back_end3.Models;
using Microsoft.EntityFrameworkCore;
using Proiect.Models;
using Proiect_InterfataLogare.Models;

namespace Proiect.Data

{
    public class AppDbContext:DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Recipe> Recipes { get; set; }
        public DbSet<RecipeIngredient> RecipeIngredients { get; set; }
        public DbSet<Ingredient> Ingredients { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Rating> Ratings { get; set; }
        public DbSet<ProductToBuy> ProductToBuy { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<RecipeIngredient>()
                .HasKey(ri => new { ri.RecipeId, ri.IngredientId });

            modelBuilder.Entity<Category>().ToTable("Category");

            modelBuilder.Entity<ProductToBuy>().ToTable("Product_to_buy");

            base.OnModelCreating(modelBuilder);
        }
    }

}
