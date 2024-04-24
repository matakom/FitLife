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
        public static async void NewSteps(string gmail, int count, DateTime start, DateTime end)
        {
            int userId = await GetUserId(gmail);

            await using (NpgsqlCommand cmd = new NpgsqlCommand("INSERT INTO physical_activities (user_id, start_time, end_time, count) " +
                                                                "VALUES (@user_id, @start_time, @end_time, @count)" +
                                                                "ON CONFLICT (user_id, start_time) " +
                                                                "DO UPDATE SET count = @count", connection))
            {
                cmd.Parameters.AddWithValue("user_id", userId);
                cmd.Parameters.AddWithValue("start_time", start);
                cmd.Parameters.AddWithValue("end_time", end);
                cmd.Parameters.AddWithValue("count", count);
                await cmd.ExecuteNonQueryAsync();
            }
        }
        public static async void NewAnonymousActivity(string gmail, string activity, DateTime start, DateTime end)
        {
            int userId = await GetUserId(gmail);

            await using (NpgsqlCommand cmd = new NpgsqlCommand("INSERT INTO digital_activities (user_id, activity, start_time, end_time) " +
                                                    "VALUES (@user_id, @activity, @start_time, @end_time)", connection))
            {
                cmd.Parameters.AddWithValue("user_id", userId);
                cmd.Parameters.AddWithValue("activity", activity);
                cmd.Parameters.AddWithValue("start_time", start);
                cmd.Parameters.AddWithValue("end_time", end);
                await cmd.ExecuteNonQueryAsync();
            }
        }
        public static async Task UserLogin(string gmail, string name)
        {
            await using (var cmd = new NpgsqlCommand("INSERT INTO users (gmail, name, registration_date, last_login_date) " +
                "VALUES (@gmail, @name, @registrationDate, @lastLoginDate)" +
                "ON CONFLICT (gmail)" +
                "DO UPDATE SET last_login_date = @lastLoginDate", connection))
            {
                cmd.Parameters.AddWithValue("gmail", gmail);
                cmd.Parameters.AddWithValue("name", name);
                cmd.Parameters.AddWithValue("registrationDate", DateTime.Now);
                cmd.Parameters.AddWithValue("lastLoginDate", DateTime.Now);
                await cmd.ExecuteNonQueryAsync();
            }
        }
        private static async Task<int> GetUserId(string gmail)
        {
            int userId = -1;
            await using (NpgsqlCommand cmd = new NpgsqlCommand("SELECT id FROM users WHERE gmail LIKE(@gmail)", connection))
            {
                cmd.Parameters.AddWithValue("gmail", gmail);

                NpgsqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    userId = Int32.Parse(reader[0].ToString());
                }
                reader.Close();
            }

            if (userId < 0)
            {
                throw new Exception("User is not present in database!");
            }
            return userId;
        
        }
        public static async Task<int> GetSteps(string gmail, DateTime time)
        {
            int user_id = await GetUserId(gmail);
            int steps = 0;
            // Will need to make a option for range
            await using (NpgsqlCommand cmd = new NpgsqlCommand("SELECT count FROM physical_activities WHERE user_id = @user_id AND start_time = @time", connection))
            {
                cmd.Parameters.AddWithValue("time", time);
                cmd.Parameters.AddWithValue("user_id", user_id);

                NpgsqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    steps = Int32.Parse(reader[0].ToString());
                }
                reader.Close();
            }

            if (steps < 0)
            {
                throw new Exception("Steps must be bigger than 0!");
            }
            return steps;
        }
    
    }
}
