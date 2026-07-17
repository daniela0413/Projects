using Microsoft.AspNetCore.Mvc;
using Proiect.Services;
using Proiect.Models;
using Proiect_InterfataLogare.Models;
using System.Text.RegularExpressions;

namespace Proiect.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;
        private readonly EmailService _emailService;

        public AuthController(AuthService authService, EmailService emailService)
        {
            _authService = authService;
            _emailService = emailService;
        }


        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var user = await _authService.ValidateUserAsync(request.Username, request.Password);
            if (user != null)
            {
                return Ok(new
                {
                    id = user.Id,
                    username = user.Username,
                    role = user.Role,
                    message = "Successful authentication!"
                });
            }
            return Unauthorized(new { message = "Incorrect username or password!" });
        }


        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] LoginRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Username) ||
                    string.IsNullOrWhiteSpace(request.Password) ||
                    string.IsNullOrWhiteSpace(request.Email))
                {
                    return BadRequest(new { message = "All fields are required!" });
                }

                
                if (request.Username.Length < 4 || request.Username.Length > 20)
                {
                    return BadRequest(new { message = "Username must be between 4 and 20 characters." });
                }

                var usernameRegex = new Regex(@"^[a-zA-Z0-9_]+$");
                if (!usernameRegex.IsMatch(request.Username))
                {
                    return BadRequest(new { message = "Username can contain only letters, numbers, and underscores. No spaces or special characters allowed." });
                }

                var passwordRegex = new Regex(@"^[a-zA-Z0-9!@#$%^&*()_+=-]+$");
                if (!passwordRegex.IsMatch(request.Password))
                {
                    return BadRequest(new { message = "Password contains invalid characters or spaces!" });
                }

                
                if (!IsValidPassword(request.Password))
                {
                    return BadRequest(new
                    {
                        message = "Password must be 8–32 characters long and include at least one uppercase letter, one lowercase letter, one digit, and one special character."
                    });
                }

                
                var email = request.Email.ToLower().Trim();
                if (!Regex.IsMatch(email, @"^(?=[a-z0-9._]{4,30}@gmail\.com$)(?!.*\.\.)(?![._])[a-z0-9._]+(?<![._])@gmail\.com$"))
                {
                    return BadRequest(new { message = "Only valid Gmail addresses are allowed. Must start and end with a letter or digit, contain no consecutive dots, and only '.', '_' are allowed." });
                }

                var success = await _authService.RegisterUserAsync(request.Username, request.Password, email);
                if (success)
                {
                    try
                    {
                        _emailService.SendCredentialsEmail(
                            email,
                            request.Username,
                            "Your account has been successfully created. You can log in now."
                        );
                    }
                    catch (Exception emailEx)
                    {
                        Console.WriteLine($"[Email ERROR] {emailEx.Message}");
                    }

                    return Ok(new { message = "Account created successfully!" });
                }

                return BadRequest(new { message = "The user already exists!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Registration error: {ex.Message}");
            }
        }
    


        private bool IsValidPassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password)) return false;
            if (password.Length < 8 || password.Length > 32) return false;
            if (!password.Any(char.IsUpper)) return false;
            if (!password.Any(char.IsLower)) return false;
            if (!password.Any(char.IsDigit)) return false;
            if (!password.Any(ch => !char.IsLetterOrDigit(ch))) return false;

            return true;
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] EmailRequest request)
        {
            var user = await _authService.FindUserByEmailAsync(request.Email);
            if (user == null)
                return NotFound(new { message = "The email does not exist in the system!" });
            try
            {
                _emailService.SendCredentialsEmail(request.Email, user.Username, $"Your password is: {user.Password}");
                return Ok(new { message = "Email sent successfully!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Error sending email: {ex.Message}" });
            }
        }
       

    }
}
