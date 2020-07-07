# frozen_string_literal: true

require 'sqlite3'
require 'singleton'

# Creates our connection to the database. Initialized as a singleton to prevent
# more than one database connection being created at any time
class PlayDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('plays.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

# Represents a single play in plays.db
class Play
  attr_accessor :id, :title, :year, :playwright_id

  def self.all
    data = PlayDBConnection.instance.execute('SELECT * FROM plays')
    data.map { |datum| Play.new(datum) }
  end

  def self.find_by_title(title)
    raise ArgumentError, 'Must specify a title' if title.empty?

    found_play = PlayDBConnection.instance.execute(<<-SQL, title)
      SELECT * 
      FROM plays 
      WHERE title = ?
    SQL
    found_play || nil
  end

  def self.find_by_playwright(name)
    raise ArgumentError, 'Must specify a playwright\'s name' if name.empty?

    found_playwright = Playwright.find_by_name(name)
    raise 'Playwright not found' if found_playwright.empty?

    found_playwright_id = found_playwright[0]['id']
    found_plays = PlayDBConnection.instance.execute(<<-SQL, found_playwright_id)
      SELECT *
      FROM plays
      WHERE playwright_id = ?
    SQL
    found_plays || nil
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @year = options['year']
    @playwright_id = options['playwright_id']
  end

  def create
    raise "#{self} already in database" if @id

    PlayDBConnection.instance.execute(<<-SQL, @title, @year, @playwright_id)
      INSERT INTO
        plays (title, year, playwright_id)
      VALUES
        (?, ?, ?)
    SQL
    self.id = PlayDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id

    PlayDBConnection.instance.execute(<<-SQL, @title, @year, @playwright_id, @id)
      UPDATE
        plays
      SET
        title = ?, year = ?, playwright_id = ?
      WHERE
        id = ?
    SQL
  end
end

# Playwright represents a single playwright in plays.db
class Playwright
  attr_accessor :name, :birth_year, :id
  def self.all
    data = PlayDBConnection.instance.execute('SELECT * FROM playwrights')
    data.map { |datum| Playwright.new(datum) }
  end

  def self.find_by_name(name)
    raise ArgumentError, 'Must specify a name' if name.empty?

    playwright_name = PlayDBConnection.instance.execute(<<-SQL, name)
      SELECT *
      FROM playwrights
      WHERE name = ?
    SQL
    playwright_name || nil
  end

  def initialize(datum)
    @id = datum['id']
    @name = datum['name']
    @birth_year = datum['birth_year']
  end

  def create
    raise "#{self} already in database" if @id

    PlayDBConnection.instance.execute(<<-SQL, @name, @birth_year)
      INSERT INTO
        playwrights (name, birth_year)
      VALUES
        (?, ?)
    SQL
    @id = PlayDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id

    PlayDBConnection.instance.execute(<<-SQL, @name, @birth_year, @id)
      UPDATE
        playwrights
      SET
        title = ?, year = ?
      WHERE
        id = ?
    SQL
  end

  def plays
    raise "#{self} not in database" unless @id

    PlayDBConnection.instance.execute(<<-SQL, @id)
      SELECT *
      FROM plays
      WHERE playwright_id = ?
    SQL
  end
end
