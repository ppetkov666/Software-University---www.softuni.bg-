namespace _03___race_condition
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;

    public class StartUp
    {
        public static void Main(string[] args)
        {
            List<int> numbers = Enumerable.Range(0, 100000).ToList();
            for (int i = 0; i < 4; i++)
            {
                Thread thread = new Thread(() =>
                {
                    while (numbers.Count > 0)
                    {
                        lock (numbers)
                        {
                            if (numbers.Count == 0)
                            {
                                break;
                            }
                        numbers.RemoveAt(numbers.Count - 1);
                        }
                    }
                });
                thread.Start();
            }
        }
    }
}
