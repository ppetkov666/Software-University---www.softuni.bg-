namespace _06___task
{
    using System;
    using System.IO;
    using System.Threading.Tasks;

    class StartUp
    {
        static void Main(string[] args)
        {

            //for (int i = 0; i < 1000; i++)
            //{
            //    Task.Run(() =>
            //    {
            //        for (int j = 0; j < 100000; j++)
            //        {

            //        }
            //    });
            //}


            //Task<int> task = Task.Run(() =>
            //{
            //    return 7;
            //});
            ////the 'safest' way to get the result from the task  - it block the current thread to get the result    
            //int result = task.GetAwaiter().GetResult();
            //Console.WriteLine(result);


            // it is called Promise
            //Task taskTwo = Task.Run(() => File.ReadAllTextAsync("test.txt"))
            //                   .ContinueWith(prevtask => File.WriteAllText("dest.txt",prevtask.Result))
            //                   .ContinueWith(prectask => Console.WriteLine("Ok!"));
            //Console.ReadKey();

            // we simulate asp.net 1000 users who are calling this method on the same time
            // these are 10 tasks , who will be distributed between all my threads.
            // One user could read from file, the other could write, the third one could return results...
            for (int i = 0; i < 10; i++)
            {
                 var result = GetResultAsync();
            }
            Console.ReadLine();

        }

        static async Task GetResultAsync()
        {
            try
            {
                // if we want to simulate exception
                //throw new Exception("error");
                string result = await Task.Run(() => File.ReadAllTextAsync("test.txt"));
                await File.WriteAllTextAsync("dest.txt", result);
                Console.WriteLine(result[0]);
            }
            catch (Exception e)
            {

                Console.WriteLine(e.Message);
            }
        }
    }
}
