namespace _06___task
{
    using System;
    using System.Threading.Tasks;

    class StartUp
    {
        static void Main(string[] args)
        {
            Task<int> task = Task.Run(() => 
            {
                return 7;
            });
            //the 'safest' way to get the result from the task  - it block the current thread to get the result    
            int result = task.GetAwaiter().GetResult();
            Console.WriteLine(result);
        }
    }
}
