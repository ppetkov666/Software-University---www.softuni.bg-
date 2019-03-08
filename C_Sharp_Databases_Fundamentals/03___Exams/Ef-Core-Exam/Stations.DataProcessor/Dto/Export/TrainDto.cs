namespace Stations.DataProcessor.Dto.Export
{
    using System;
    public class TrainDto
    {
        public string TrainNumber { get; set; }
        public int DelayedCount { get; set; }
        public string MaxDelayedTime { get; set; }

    }
}
