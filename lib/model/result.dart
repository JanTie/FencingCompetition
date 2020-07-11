class Result {
  final String competitorName;
  final int victoryCount;
  final int points;
  final int pointsTaken;

  int get pointIndex => points - pointsTaken;

  Result(this.competitorName, this.victoryCount, this.points, this.pointsTaken);
}
