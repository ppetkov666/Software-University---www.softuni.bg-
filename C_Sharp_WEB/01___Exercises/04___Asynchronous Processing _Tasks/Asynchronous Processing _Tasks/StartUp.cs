namespace Asynchronous_Processing__Tasks
{
    using System;
    using System.Threading;

    public class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("first");
            Thread parallelThread = new Thread(DoCalculations);
            parallelThread.Start();
            Console.WriteLine("Processing... please wait!");
            parallelThread.Join();
            Console.WriteLine("Done");
        }
        public static void DoCalculations()
        {
            for (int i = 0; i < 10; i++)
            {
                //Thread.Sleep(1000); - it means the currect thread (parallelThread) will sleep for each second
                Thread.Sleep(1000);
                Console.WriteLine(i);
            }
        }
    }
}
