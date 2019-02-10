namespace _05___flip_images
{
    using System;
    using System.Collections.Generic;
    using System.Drawing;
    using System.IO;
    using System.Threading.Tasks;

    public class StartUp
    {
        const string resultDir = "Result";
        public static void Main(string[] args)
        {
            string currentDir = Directory.GetCurrentDirectory();
            DirectoryInfo dirInfo = new DirectoryInfo(currentDir + "\\Images");

            FileInfo[] files = dirInfo.GetFiles();

            if (Directory.Exists(resultDir))
            {
                Directory.Delete(resultDir, true);
            }

            Directory.CreateDirectory(resultDir);
            List<Task> tasks = new List<Task>();
            foreach (var file in files)
            {
                Task task = Task.Run(() =>
                {
                    var image = Image.FromFile(file.FullName);
                    image.RotateFlip(RotateFlipType.RotateNoneFlipY);
                    image.Save($"{resultDir}\\flipped{file.Name}");

                    Console.WriteLine($"{file.Name} is processed..");
                });

                tasks.Add(task);
            }

            try
            {

            Task.WaitAll(tasks.ToArray());

            }
            catch (AggregateException ex)
            {
                
                foreach (var exception in ex.InnerExceptions)
                {
                    Console.WriteLine(exception);
                }
            }

            Console.WriteLine("All tasks are completed !");
        }
    }
}
