CREATE TABLE Directors (
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX),
)

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear DATETIME NOT NULL,
	[Length] INT NOT NULL,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Rating INT NOT NULL,
	Notes NVARCHAR(MAX)
) 



INSERT INTO Directors (DirectorName, Notes)
VALUES  ('Director1', 'Notes1'),
		('Director2', 'Notes2'),
		('Director3', 'Notes3'),
		('Director4', 'Notes4'),
		('Director5', 'Notes5')

INSERT INTO Categories (CategoryName, Notes)
VALUES  ('Category1', 'Notes1'),
		('Category2', 'Notes2'),
		('Category3', 'Notes3'),
		('Category4', 'Notes4'),
		('Category5', 'Notes5')

INSERT INTO Genres (GenreName, Notes)
VALUES  ('Genre1', 'Notes1'),
		('Genre2', 'Notes2'),
		('Genre3', 'Notes3'),
		('Genre4', 'Notes4'),
		('Genre5', 'Notes5')


INSERT INTO Movies ( Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes)
VALUES  ('Title1', 1, GETDATE(), 15, 1, 1, 10, 'Notes1'),
		('Title2', 1, GETDATE(), 15, 1, 1, 10, 'Notes2'),
		('Title3', 1, GETDATE(), 15, 1, 1, 10, 'Notes3'),
		('Title4', 1, GETDATE(), 15, 1, 1, 10, 'Notes4'),
		('Title5', 1, GETDATE(), 15, 1, 1, 10, 'Notes5')