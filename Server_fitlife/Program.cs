using System.Net;
using System.Text;

namespace Server_fitlife
{
    internal class Program
    {
        static void Main()
        {
            Listener listener = new Listener();
            listener.Start();
            while (true)
            {
                Thread.Sleep(100);
            }
        }
    }

    class Listener
    {
        public int port = 80;
        public string ipAddress = "192.168.1.111";

        private HttpListener _listener;

        public void Start()
        {
            Console.WriteLine("Start");
            _listener = new HttpListener();
            _listener.Prefixes.Add($"http://{ipAddress}:{port}/");
            _listener.Start();
            Receive();
        }

        public void Stop()
        {
            Console.WriteLine("Stop");
            _listener.Stop();
        }

        private void Receive()
        {
            Console.WriteLine("Receive");
            _listener.BeginGetContext(new AsyncCallback(ListenerCallback), _listener);
        }

        private void ListenerCallback(IAsyncResult result)
        {
            Console.WriteLine("Callback");
            if (_listener.IsListening)
            {
                var context = _listener.EndGetContext(result);
                var request = context.Request;

                Console.WriteLine($"{request.Url}");


                var response = context.Response;
                response.StatusCode = 200;
                byte[] data = Encoding.UTF8.GetBytes("ok");
                response.OutputStream.Write(data, 0, data.Length);
                response.Close();

                Receive();
            }
        }
    }

}