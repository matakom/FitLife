using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net;
using System.Text;

namespace Server_fitlife
{
    class Program
    {
        public static HttpListener listener;
        public static string url = "http://10.0.3.101/";

        public static async Task HandleIncomingConnections()
        {
            bool runServer = true;

            bool success = await Database.StartDatabase();
            
            if(!success)
            {
                throw new Exception("Database connection start error");
            }

            while (runServer)
            {
                HttpListenerContext context = await listener.GetContextAsync();
                HttpListenerRequest request = context.Request;
                HttpListenerResponse response = context.Response;
                string textResponse = "";

                Console.WriteLine("-------------------------------------------------------------------");

                string body = StreamToString(request.InputStream);
                JObject json = JsonConvert.DeserializeObject<dynamic>(body);

                await Console.Out.WriteLineAsync(json.ToString());
                switch (request.Url.AbsolutePath)
                {
                    case "/login":
                        await Console.Out.WriteLineAsync("Login");
                        await Database.UserLogin(json["mail"].ToString(), json["name"].ToString());
                        break;
                    case "/newKnownActivity":
                        await Console.Out.WriteLineAsync("Known Activity");
                        KnownActivity(json);
                        break;
                    case "/newAnonymousActivity":
                        await Console.Out.WriteLineAsync("Anonymous Activity");
                        AnonymousActivity(json);
                        break;
                    case "/getSteps":
                        await Console.Out.WriteLineAsync("Get Steps");
                        int steps = await GetSteps(json);
                        textResponse += steps.ToString();
                        break;
                    default:
                        await Console.Out.WriteLineAsync("Wrong path");
                        textResponse = "WRONG PATH";
                        break;
                }


                byte[] data = Encoding.UTF8.GetBytes(textResponse);
                response.ContentType = "text/plain";
                response.ContentEncoding = Encoding.UTF8;
                response.ContentLength64 = data.LongLength;

                await response.OutputStream.WriteAsync(data, 0, data.Length);
                response.Close();
            }
        }

        static async Task<int> GetSteps(JObject json)
        {
            DateTime time = Convert.ToDateTime(json["time"]);
            string gmail = json["user"].ToString() ?? throw new Exception("Property is null, which it should not be");

            return await Database.GetSteps(gmail, time);
        }
        static void AnonymousActivity(JObject json)
        {
            DateTime start = Convert.ToDateTime(json["startTime"]);
            DateTime end = Convert.ToDateTime(json["endTime"]);
            string gmail = json["user"].ToString() ?? throw new Exception("Property is null, which it should not be");
            string activity = json["activity"].ToString() ?? throw new Exception("Property is null, which it should not be");

            Database.NewAnonymousActivity(gmail, activity, start, end);
        }
        static void KnownActivity(JObject json)
        {
            if ((json["activity"].ToString() ?? throw new Exception("Property is null, which it should not be")) == "steps")
            {
                int count = Convert.ToInt16(json["count"]);
                DateTime start = Convert.ToDateTime(json["startTime"]);
                DateTime end = Convert.ToDateTime(json["endTime"]);
                string gmail = json["user"].ToString() ?? throw new Exception("Property is null, which it should not be");
                Database.NewSteps(gmail, count, start, end);
            }
        }
        static void Main(string[] args)
        {
            listener = new HttpListener();
            listener.Prefixes.Add(url);
            listener.Start();
            Console.WriteLine("Listening for connections on {0}", url);

            Task listenTask = HandleIncomingConnections();
            listenTask.GetAwaiter().GetResult();

            listener.Close();
        }
        public static string StreamToString(Stream stream)
        {
            using (StreamReader reader = new StreamReader(stream, Encoding.UTF8))
            {
                return reader.ReadToEnd();
            }
        }
    }
}
