using Newtonsoft.Json;
using System.Net;
using System.Text;

namespace Server_fitlife
{
    class Program
    {
        public static HttpListener listener;
        public static string url = "http://172.24.128.1:80/";
        public static string homeUrl = "http://192.168.1.240:80/";
        public static bool AtHome = true;

        public static async Task HandleIncomingConnections()
        {
            bool runServer = true;

            while (runServer)
            {
                HttpListenerContext context = await listener.GetContextAsync();
                HttpListenerRequest request = context.Request;
                HttpListenerResponse response = context.Response;
                string textResponse = "";

                Console.WriteLine("-------------------------------------------------------------------");
                Console.WriteLine(request.HttpMethod);
                Console.WriteLine(request.Url.AbsolutePath);
                Console.WriteLine(request.Url.Query);

                var queryParams = System.Web.HttpUtility.ParseQueryString(request.Url.Query);

                switch (request.Url.AbsolutePath)
                {
                    case "/newKnownActivity":
                        string body = StreamToString(request.InputStream);
                        Console.WriteLine(body);
                        textResponse = "understood";
                        break;
                    case "/newAnonymousActivity":
                        body = StreamToString(request.InputStream);
                        Console.WriteLine(body);
                        textResponse = "I do not know this one...";
                        break;
                }

                textResponse += " - " + queryParams["user"];

                byte[] data = Encoding.UTF8.GetBytes(textResponse);
                response.ContentType = "text/plain";
                response.ContentEncoding = Encoding.UTF8;
                response.ContentLength64 = data.LongLength;

                await response.OutputStream.WriteAsync(data, 0, data.Length);
                response.Close();
            }
        }

        static void Main(string[] args)
        {
            if(AtHome)
            {
                url = homeUrl;
            }
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
