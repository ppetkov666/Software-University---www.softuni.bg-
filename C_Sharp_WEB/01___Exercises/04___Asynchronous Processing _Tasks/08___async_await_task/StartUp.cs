namespace _08___async_await_task
{
    using System;
    using System.Collections.Generic;
    using System.Threading;
    using System.Threading.Tasks;

    public class StartUp
    {
        static void Main(string[] args)
        {
            DoWork();
            Console.WriteLine("Loading resourses... Please Wait");
            Console.WriteLine(@"Type ""exit"" to close the program");
            while (true)
            {
                string input = Console.ReadLine();
                if (input == "exit")
                {
                    break;
                }
            }
        }
        public static async void DoWork()
        {
            List<Task> tasks = new List<Task>();
           

            for (int i = 0; i < 10; i++)
            {
                tasks.Add(Task.Run(async () =>
                {
                    await Calculate();
                    
                }));
                
            }
            // without wait the currect task is blocked and is waiting till all the calculations are done
            //Task.WaitAll(tasks.ToArray());
            // with await the current thread is released and actually is not waithing, and only after all the operations are done then 
            // code continue from this point
            await Task.WhenAll(tasks.ToArray());
            Console.WriteLine("the program is finished");
        }
        public static async Task Calculate()
        {
            Thread.Sleep(3000);
            await Task.Run(() =>
            {
            Console.WriteLine("Calculated result");
            });

            


        }
    }
}
