using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DotNetEnv;
using Npgsql;
using NpgsqlTypes;

namespace Server_fitlife
{
    public static class Database
    {
        static NpgsqlConnection connection;
        public static async Task<bool> StartDatabase()
        {
            DotNetEnv.Env.Load(@"../../../../.env");
            string password = Environment.GetEnvironmentVariable("MATAKOM_USER_DATABASE_PASSWORD");
            string username = "matakom";

            string connectionString = $"Host=localhost;Username={username};Password={password};Database=fitlife";

            connection = new NpgsqlConnection(connectionString);
            await connection.OpenAsync();

            if(connection.State == System.Data.ConnectionState.Open)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public static async void UserLogin(string gmail, string firstName, string lastName)
        {
            await using (var cmd = new NpgsqlCommand("INSERT INTO users (gmail, first_name, last_name, registration_date, last_login_date) VALUES (@gmail, @firstName, @lastName, @registrationDate, @lastLoginDate)", connection))
            {
                cmd.Parameters.AddWithValue("gmail", gmail);
                cmd.Parameters.AddWithValue("firstName", firstName);
                cmd.Parameters.AddWithValue("lastName", lastName);
                cmd.Parameters.AddWithValue("registrationDate", DateTime.Now);
                cmd.Parameters.AddWithValue("lastLoginDate", DateTime.Now);
                await cmd.ExecuteNonQueryAsync();
            }
        }
    }
}
