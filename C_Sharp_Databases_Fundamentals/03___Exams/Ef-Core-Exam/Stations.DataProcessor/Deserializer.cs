using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
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
                if (!Enum.TryParse(trainDto.Type, out type))
                {
                    // do work , but because in this task our input is guaranteed we dont proceed with this check
                }

                TrainSeat[] trainseat = trainDto.Seats.Select(s => new TrainSeat
                {
                    Quantity = s.Quantity.Value,
                    SeatingClass = context.SeatingClasses.SingleOrDefault(sc => sc.Name == s.Name && sc.Abbreviation == s.Abbreviation),
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
            TripDto[] deserializedTrip = JsonConvert.DeserializeObject<TripDto[]>(jsonString, new JsonSerializerSettings()
            {
                NullValueHandling = NullValueHandling.Ignore
            });

            StringBuilder sb = new StringBuilder();

            List<Trip> validTrips = new List<Trip>();

            foreach (var tripDto in deserializedTrip)
            {
                if (!IsValid(tripDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                Train train = context.Trains.SingleOrDefault(t => t.TrainNumber == tripDto.Train);
                Station originStation = context.Stations.SingleOrDefault(s => s.Name == tripDto.OriginStation);
                Station destinationStation = context.Stations.SingleOrDefault(s => s.Name == tripDto.DestinationStation);

                if (train == null || originStation == null || destinationStation == null)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                DateTime departureTime = DateTime.ParseExact(tripDto.DepartureTime, "dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);
                DateTime arrivalTime = DateTime.ParseExact(tripDto.ArrivalTime, "dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);
                TimeSpan timeDifference;
                if (tripDto.TimeDifference != null)
                {
                    timeDifference = TimeSpan.ParseExact(tripDto.TimeDifference, @"hh\:mm", CultureInfo.InvariantCulture);
                }

                if (departureTime > arrivalTime)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                TripStatus tripStatus = Enum.Parse<TripStatus>(tripDto.Status);

                Trip trip = new Trip
                {
                    Train = train,
                    OriginStation = (Station)originStation,
                    DestinationStation = destinationStation,
                    DepartureTime = departureTime,
                    ArrivalTime = arrivalTime,
                    Status = tripStatus,
                    TimeDifference = timeDifference,
                };

                validTrips.Add(trip);
                sb.AppendLine($"Trip from {tripDto.OriginStation} to {tripDto.DestinationStation} imported.");
            }

            context.Trips.AddRange(validTrips);
            context.SaveChanges();
            string result = sb.ToString();
            return result;
        }

        public static string ImportCards(StationsDbContext context, string xmlString)
        {

            XmlSerializer serializer = new XmlSerializer(typeof(CardDto[]), new XmlRootAttribute("Cards"));
            CardDto[] deserializedCards = (CardDto[])serializer.Deserialize(new MemoryStream(Encoding.UTF8.GetBytes(xmlString)));

            StringBuilder sb = new StringBuilder();

            List<CustomerCard> validCards = new List<CustomerCard>();

            foreach (CardDto cardDto in deserializedCards)
            {

                if (!IsValid(cardDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                CardType cardType = Enum.TryParse<CardType>(cardDto.CardType, out CardType cardTypeParsed) ?
                    cardTypeParsed : CardType.Normal;

                CustomerCard card = new CustomerCard
                {
                    Name = cardDto.Name,
                    Age = cardDto.Age,
                    Type = cardType,
                };

                validCards.Add(card);
                sb.AppendLine(string.Format(SuccessMessage, cardDto.Name));
            }
            context.Cards.AddRange(validCards);
            context.SaveChanges();

            string result = sb.ToString();
            return result;
        }

        public static string ImportTickets(StationsDbContext context, string xmlString)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(TicketDto[]), new XmlRootAttribute("Tickets"));
            TicketDto[] deserializedTickets = (TicketDto[])serializer.Deserialize(new MemoryStream(Encoding.UTF8.GetBytes(xmlString)));

            StringBuilder sb = new StringBuilder();

            List<Ticket> validTickets = new List<Ticket>();

            foreach (TicketDto ticketDto in deserializedTickets)
            {

                if (!IsValid(ticketDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                DateTime departureTime = DateTime.ParseExact(ticketDto.Trip.DepartureTime, "dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);
                Trip trip = context.Trips.SingleOrDefault(t => t.OriginStation.Name == ticketDto.Trip.OriginStation      &&
                                                          t.DestinationStation.Name == ticketDto.Trip.DestinationStation &&
                                                          t.DepartureTime == departureTime);

                if (trip == null)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }
                CustomerCard card = null;
                if (ticketDto.Card != null)
                {
                    card = context.Cards.SingleOrDefault(c => c.Name == ticketDto.Card.Name);
                    if (card == null)
                    {
                        sb.AppendLine(FailureMessage);
                        continue;
                    }
                }

                string seatingClassAbbreviation = ticketDto.Seat.Substring(0, 2);
                int quantity = int.Parse(ticketDto.Seat.Substring(2));

                bool trainseatsExist = context
                    .TrainSeats
                    .Any(ts => ts.SeatingClass.Abbreviation == seatingClassAbbreviation &&
                                                            ts.Quantity <= quantity);
                string seat = ticketDto.Seat;

                if (!trainseatsExist)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                Ticket ticket = new Ticket
                {
                    Trip = trip,
                    CustomerCard = card,
                    Price = ticketDto.Price,
                    SeatingPlace = seat,
                };
                validTickets.Add(ticket);
                sb.AppendLine($"Ticket from {ticket.Trip.OriginStation.Name} to {ticket.Trip.DestinationStation.Name} " +
                    $"departing at {ticket.Trip.DepartureTime.ToString("dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture)} imported.");
            }
            context.Tickets.AddRange(validTickets);
            context.SaveChanges();
            string result = sb.ToString();
            return result;
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