using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;

namespace Proiect.Services
{
    public class EmailService
    {
        private readonly IConfiguration _config;

        public EmailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendEmailAsync(string to, string subject, string body)
        {
            var from = _config["Email:From"];
            var password = _config["Email:Password"];
            var smtp = _config["Email:Smtp"];
            var port = int.Parse(_config["Email:Port"]);

            using var client = new SmtpClient(smtp)
            {
                Port = port,
                Credentials = new NetworkCredential(from, password),
                EnableSsl = true
            };

            var mail = new MailMessage
            {
                From = new MailAddress(from, "MyPantryChef 🍽️"),
                Subject = subject,
                Body = body,
                IsBodyHtml = false
            };

            mail.To.Add(to);

            try
            {
                Console.WriteLine($" Sending email to {to} via {smtp}:{port}...");
                await client.SendMailAsync(mail);
                Console.WriteLine(" Email sent successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Error sending email: {ex.Message}");
                throw; 
            }
        }

        public void SendCredentialsEmail(string toEmail, string username, string customMessage)
        {
            var from = _config["Email:From"];
            var pass = _config["Email:Password"];
            var host = _config["Email:Smtp"];
            var port = int.Parse(_config["Email:Port"]);

            var fromAddress = new MailAddress(from, "MyPantryChef");
            var toAddress = new MailAddress(toEmail);

            string subject = "Account confirmation - MyPantryChef";
            string body = $"Hello {username},\n\n{customMessage}\n\nTeam MyPantryChef 🍽️";

            var smtp = new SmtpClient
            {
                Host = host,
                Port = port,
                EnableSsl = true,
                Credentials = new NetworkCredential(fromAddress.Address, pass)
            };

            using var message = new MailMessage(fromAddress, toAddress)
            {
                Subject = subject,
                Body = body,
                IsBodyHtml = false
            };

            var sw = System.Diagnostics.Stopwatch.StartNew();

            try
            {
                Console.WriteLine($" Sending email to {toEmail} via {host}:{port}...");
                smtp.Send(message);
                Console.WriteLine(" Email sent successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Error sending email: {ex.Message}");
                throw;
            }
            finally
            {
                sw.Stop();
                Console.WriteLine($" Email sending time: {sw.ElapsedMilliseconds} ms");
                smtp.Dispose();
            }
        }
    }
}
