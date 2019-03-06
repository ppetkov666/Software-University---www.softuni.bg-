using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using AutoMapper;
using Newtonsoft.Json;
using Stations.Data;
using Stations.DataProcessor.Dto.Import;
using Stations.Models;
using Stations.Models.Enums;

namespace Stations.DataProcessor
{
    public static class Deserializer
    {
        private const string FailureMessage = "Invalid data format.";
        private const string SuccessMessage = "Record {0} successfully imported.";

        public static string ImportStations(StationsDbContext context, string jsonString)
        {
            StringBuilder sb = new StringBuilder();

            StationDto[] deserializedStations = JsonConvert.DeserializeObject<StationDto[]>(jsonString);

            List<Station> validStations = new List<Station>();

            foreach (StationDto stationDto in deserializedStations)
            {
                //if we dont use this method IsValid we have to do it by hand for each property for example:
                //if (stationDto.Name.Length > 50 )
                //{
                //    // do work
                //}
                if (!IsValid(stationDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                // this is not part of validation - it is part of the task we must check and set
                if (stationDto.Town == null)
                {
                    stationDto.Town = stationDto.Name;
                }

                Boolean stationAlreadyExist = validStations.Any(s => s.Name == stationDto.Name);
                if (stationAlreadyExist)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                // this is the first approach, the other is with autoMapper
                //Station station = new Station()
                //{
                //    Name = stationDto.Name,
                //    Town = stationDto.Town,
                //};
                Station station = Mapper.Map<Station>(stationDto);
                validStations.Add(station);
                // we use string format because pass parameter into SuccessMessage const
                sb.AppendLine(string.Format(SuccessMessage, stationDto.Name));
            }

            context.Stations.AddRange(validStations);
            context.SaveChanges();

            string result = sb.ToString();
            return result;
        }

        public static string ImportClasses(StationsDbContext context, string jsonString)
        {
            StringBuilder sb = new StringBuilder();

            SeatingClassDto[] deserializedClasses = JsonConvert.DeserializeObject<SeatingClassDto[]>(jsonString);
            List<SeatingClass> validClasses = new List<SeatingClass>();

            foreach (SeatingClassDto seatingClassDto in deserializedClasses)
            {

                if (!IsValid(seatingClassDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                Boolean classAlreadyExist = validClasses.Any(c => c.Name == seatingClassDto.Name ||
                                                          c.Abbreviation == seatingClassDto.Abbreviation);

                if (classAlreadyExist)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                SeatingClass seatingClass = Mapper.Map<SeatingClass>(seatingClassDto);
                validClasses.Add(seatingClass);
                sb.AppendLine(string.Format(SuccessMessage, seatingClassDto.Name));
            }
            context.SeatingClasses.AddRange(validClasses);
            context.SaveChanges();
            string result = sb.ToString();
            return result;
        }

        public static string ImportTrains(StationsDbContext context, string jsonString)
        {

            TrainDto[] deserializedTrains = JsonConvert.DeserializeObject<TrainDto[]>(jsonString, new JsonSerializerSettings()
            {
                NullValueHandling = NullValueHandling.Ignore
            });

            StringBuilder sb = new StringBuilder();

            List<Train> validTrains = new List<Train>();

            foreach (TrainDto trainDto in deserializedTrains)
            {

                if (!IsValid(trainDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                bool trainAlreadyExist = validTrains.Any(t => t.TrainNumber == trainDto.TrainNumber);
                if (trainAlreadyExist)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }


                Boolean seatsAreValid = trainDto.Seats.All(s => IsValid(s));

                if (!seatsAreValid)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                //we check in db if seating class name and abreviation are the same as the one who we have in trainDto.Seats
                bool seatingClassesAreValid = trainDto
                    .Seats
                    .All(s => context.SeatingClasses.Any(sc => sc.Name == s.Name && 
                                                       sc.Abbreviation == s.Abbreviation));
                if (!seatingClassesAreValid)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                TrainType type;
                Enum.TryParse(trainDto.Type,out type);

                TrainSeat[] trainseat = trainDto.Seats.Select(s => new TrainSeat
                {
                    Quantity = s.Quantity.Value,
                    SeatingClass = context.SeatingClasses.SingleOrDefault(sc=>sc.Name == s.Name && sc.Abbreviation == s.Abbreviation),
                }).ToArray();

                Train train = new Train()
                {
                    TrainNumber = trainDto.TrainNumber,
                    Type = type,
                    TrainSeats = trainseat,
                };

                validTrains.Add(train);
                sb.AppendLine(string.Format(SuccessMessage, trainDto.TrainNumber));
            }
            context.Trains.AddRange(validTrains);
            context.SaveChanges();
            string result = sb.ToString();
            return result;
        }

        public static string ImportTrips(StationsDbContext context, string jsonString)
        {
            throw new NotImplementedException();
        }

        public static string ImportCards(StationsDbContext context, string xmlString)
        {
            throw new NotImplementedException();
        }

        public static string ImportTickets(StationsDbContext context, string xmlString)
        {
            throw new NotImplementedException();
        }

        private static bool IsValid(object obj)
        {
            // what this method does is basically goes to each property and check data anotations 
            var validationContext = new System.ComponentModel.DataAnnotations.ValidationContext(obj);
            List<ValidationResult> validationResults = new List<ValidationResult>();

            Boolean isValid = Validator.TryValidateObject(obj, validationContext, validationResults, true);
            return isValid;
        }
    }
}