namespace _07___task
{
    using System;
    using System.Threading;
    using System.Threading.Tasks;
    public class StartUp
    {
        private static string result;
        static void Main(string[] args)
        {
            Console.WriteLine("Calculating...");
            Task.Run(()=>Calculate());
            Console.WriteLine("Enter Command");
            while (true)
            {
                string input = Console.ReadLine();
                if (input == "show")
                {
                    if (result == null)
                    {
                        Console.WriteLine("Still calculating...Please wait!");
                    }
                    else
                    {
                        Console.WriteLine($"Result is : {result}");
                    }
                }
                if (input == "exit")
                {
                    break;
                }
            }
            
        }
        public static void Calculate()
        {
            Thread.Sleep(7000);
            result = "50";
        }
    }
}
