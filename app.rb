require 'sinatra'

require 'library_api'
require 'google/protobuf/well_known_types'

PROTOBUF_MIME = "application/x-protobuf".freeze

def protobuf(msg)
  response.headers['X-Message-Class'] = msg.class.descriptor.msgclass.name

  content_type PROTOBUF_MIME
  msg.to_proto
end

BOOKS = []

welsh = LibraryAPI::Author.new(id: 1, name: "Irvine Welsh", birthday: Google::Protobuf::Timestamp.new)
welsh.birthday.from_time(Time.utc(1967,9,27))

adams = LibraryAPI::Author.new(id: 2, name: "Douglas Adams", birthday: Google::Protobuf::Timestamp.new)
adams.birthday.from_time(Time.utc(1952,3,11))

rowling = LibraryAPI::Author.new(id: 3, name: "J.K. Rowling", birthday: Google::Protobuf::Timestamp.new)
rowling.birthday.from_time(Time.utc(1965,7,31))

BOOKS << LibraryAPI::Book.new(id: 1, author: welsh, title: "Trainspotting")
BOOKS << LibraryAPI::Book.new(id: 2, author: adams, title: "The Hitchhiker's Guide to the Galaxy")
BOOKS << LibraryAPI::Book.new(id: 3, author: rowling, title: "Harry Potter and the Philosopher's Stone")
BOOKS << LibraryAPI::Book.new(id: 4, author: rowling, title: "Harry Potter and the Chamber of Secrets")
BOOKS << LibraryAPI::Book.new(id: 5, author: rowling, title: "Harry Potter and the Prisoner of Azkaban")
BOOKS << LibraryAPI::Book.new(id: 6, author: rowling, title: "Harry Potter and the Goblet of Fire")

get '/books' do
  msg = LibraryAPI::Responses::GetBooks.new

  BOOKS.each do |book|
    msg.books << book
  end

  protobuf msg
end

post '/books' do
  raise "Incorrect type" unless request.env['CONTENT_TYPE'] == PROTOBUF_MIME
  raise "Incorrect class" unless request.env['HTTP_X_MESSAGE_CLASS'] == 'LibraryAPI.Book'

  BOOKS << LibraryAPI::Book.decode(request.body.read)

  status 204
  ""
end
