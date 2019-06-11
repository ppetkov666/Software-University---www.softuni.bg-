namespace _02___task
{
    using System;
    using System.Threading;

    public class StartUp
    {
        static void Main(string[] args)
        {
            Console.WriteLine("first");
            Thread parallelThread = new Thread(DoCalculations);
            parallelThread.Start();
            Console.WriteLine("Processing... please wait!");
            while (true)
            {
                string input = Console.ReadLine();
                Console.WriteLine("------");
                Console.WriteLine(input);
                Console.WriteLine("------");
                if (input == "end")
                {
                    break;
                }
            }
            parallelThread.Join();
            Console.WriteLine("Done");
        }
        public static void DoCalculations()
        {
            for (int i = 0; i < 10; i++)
            {
                //Thread.Sleep(1000); - it means the currect thread (parallelThread) will sleep for each second
                Thread.Sleep(1000);
                //Console.WriteLine(i);
            }
        }
    }
}
