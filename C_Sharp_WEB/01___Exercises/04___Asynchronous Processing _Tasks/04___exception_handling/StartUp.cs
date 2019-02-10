namespace _04___exception_handling
{
    using System;
    using System.Threading;

    public class StartUp
    {
        public static void Main(string[] args)
        {
            //try
            //{
            //    Thread thread = new Thread(DoWork);
            //    thread.Start();
            //}
            //catch (Exception ex)
            //{

            //    Console.WriteLine("Cought exception");
            //}

            // this is the right way - exception must be catch in the thread
            Thread thread1 = new Thread(DoWork1);
            thread1.Start();
        }
        public static void DoWork()
        {
            throw new InvalidOperationException();
        }
        public static void DoWork1()
        {
            try
            {

            throw new InvalidOperationException();
            }
            catch (Exception)
            {

                Console.WriteLine("Cought");
            }
        }
    }
}
