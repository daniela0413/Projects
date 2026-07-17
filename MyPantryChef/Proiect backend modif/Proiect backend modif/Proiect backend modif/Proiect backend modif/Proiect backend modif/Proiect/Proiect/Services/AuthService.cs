using Microsoft.EntityFrameworkCore;
using Proiect.Data;
using Proiect.Models;

namespace Proiect.Services
{
    public class AuthService
    {
        private readonly AppDbContext _context;

        public AuthService(AppDbContext context)
        {
            _context = context; 
        }


        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == username && u.Password == password);

            return user;
        }


        public async Task<bool> RegisterUserAsync(string username, string password, string email)
        {
            var normalizedEmail = email.Trim().ToLower();

           
            bool userExists = await _context.Users.AnyAsync(u =>
                u.Username == username || u.Email.ToLower() == normalizedEmail);

            if (userExists)
                return false;

            var newUser = new User
            {
                Username = username,
                Password = password,
                Email = normalizedEmail,
                Role = "User" 
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();
            return true;
        }



        public async Task<User?> FindUserByEmailAsync(string email)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
        }
    }
}
