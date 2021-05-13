module CreateNextUrl
  # @return [String]
  # @param [String] url
  # @param [Integer] next_page
  def create_next_url(url, next_page)
    return nil if next_page.nil?
    uri = get_uri(url)
    query = query_params(uri)
    query["page"] = next_page
    uri.query = Rack::Utils.build_query(query)
    uri
  end

  # @return [URI::Generic]
  # @param [String] url
  def get_uri(url)
    URI.parse(url)
  end

  # @return [Object] query params
  # @param [String] uri
  def query_params(uri)
    Rack::Utils.parse_query(uri.query)
  end
end