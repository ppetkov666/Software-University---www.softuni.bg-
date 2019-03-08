using System;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using Stations.Data;
using Stations.DataProcessor.Dto.Export;
using Stations.Models;
using Stations.Models.Enums;

namespace Stations.DataProcessor
{
	public class Serializer
	{
		public static string ExportDelayedTrains(StationsDbContext context, string dateAsString)
		{
			DateTime date = DateTime.ParseExact(dateAsString, "dd/MM/yyyy", CultureInfo.InvariantCulture);
            TrainDto[] delayed = context
                .Trains
                .Where(tr => tr.Trips.Any(t => t.Status == TripStatus.Delayed && t.DepartureTime <= date))
                .Select(t => new
                {
                    t.TrainNumber,
                    DelayedTrips = t.Trips
                    .Where(tr => tr.Status == TripStatus.Delayed && tr.DepartureTime <= date)
                    // if i dont make it to array it will throw error - reducible node
                    .ToArray()
                    //.Count(),
                    //MaxDelayedTime = t.Trips
                    //.Where(tr => tr.Status == TripStatus.Delayed && tr.DepartureTime <= date)
                    //.Max(tr=>tr.TimeDifference)
                })
                .Select(t => new TrainDto
                {
                    TrainNumber = t.TrainNumber,
                    DelayedCount = t.DelayedTrips.Count(),
                    MaxDelayedTime = t.DelayedTrips.Max(tr => tr.TimeDifference).ToString(),
                })
                .OrderByDescending(t=>t.DelayedCount)
                .ThenByDescending(t=>t.MaxDelayedTime)
                .ThenByDescending(t=>t.TrainNumber)
				.ToArray();

            string json = JsonConvert.SerializeObject(delayed, Newtonsoft.Json.Formatting.Indented);
			return json;
		}

		public static string ExportCardsTicket(StationsDbContext context, string cardType)
		{
            var cardTypeParsed = Enum.Parse<CardType>(cardType);

            StringBuilder sb = new StringBuilder();

            CardDto[] cards = context
                .Cards
                .Where(c => c.Type == cardTypeParsed && c.BoughtTickets.Any())
                .Select(c => new CardDto
                {
                    Name = c.Name,
                    Type = c.Type.ToString(),
                    Tickets = c.BoughtTickets.Select(t => new TicketDto
                    {
                        OriginStation = t.Trip.OriginStation.Name,
                        DestinationStation = t.Trip.DestinationStation.Name,
                        DepartureTime = t.Trip.DepartureTime.ToString(string.Format("dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture))
                    }).ToArray()
                })
                .OrderBy(c => c.Name)
                .ToArray();
            XmlSerializer serializer = new XmlSerializer(typeof(CardDto[]), new XmlRootAttribute("Cards"));
            
            
            serializer.Serialize(new StringWriter(sb), cards, new XmlSerializerNamespaces(new[] {XmlQualifiedName.Empty}));
            string result = sb.ToString();
            return result;
		}
	}
}