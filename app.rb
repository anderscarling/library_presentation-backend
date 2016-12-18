require 'sinatra'

require 'library_api'

PROTOBUF_MIME = "application/x-protobuf".freeze

def protobuf(msg)
  response.headers['X-Message-Class'] = msg.class.descriptor.msgclass.name

  content_type PROTOBUF_MIME
  msg.to_proto
end

BOOKS = []
BOOKS << LibraryAPI::Book.new(id: 1, author: "Irvine Welsh", title: "Trainspotting")
BOOKS << LibraryAPI::Book.new(id: 2, author: "Douglas Adams", title: "The Hitchhiker's Guide to the Galaxy")
BOOKS << LibraryAPI::Book.new(id: 3, author: "J.K. Rowling", title: "Harry Potter and the Philosopher's Stone")
BOOKS << LibraryAPI::Book.new(id: 4, author: "J.K. Rowling", title: "Harry Potter and the Chamber of Secrets")
BOOKS << LibraryAPI::Book.new(id: 5, author: "J.K. Rowling", title: "Harry Potter and the Prisoner of Azkaban")
BOOKS << LibraryAPI::Book.new(id: 6, author: "J.K. Rowling", title: "Harry Potter and the Goblet of Fire")

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
