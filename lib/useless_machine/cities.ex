defmodule UselessMachine.Cities do

  # @long %{
  #   ams: "Amsterdam, Netherlands",
  #   iad: "Ashburn, Virginia (US)",
  #   atl: "Atlanta, Georgia (US)" ,
  #   bog: "Bogotá, Colombia",
  #   bos: "Boston, Massachusetts (US)",
  #   otp: "Bucharest, Romania",
  #   ord: "Chicago, Illinois (US)",
  #   dfw: "Dallas, Texas (US)",
  #   den: "Denver, Colorado (US)",
  #   eze: "Ezeiza, Argentina",
  #   fra: "Frankfurt, Germany",
  #   gdl: "Guadalajara, Mexico",
  #   hkg: "Hong Kong, Hong Kong",
  #   jnb: "Johannesburg, South Africa",
  #   lhr: "London, United Kingdom",
  #   lax: "Los Angeles, California (US)",
  #   mad: "Madrid, Spain",
  #   mia: "Miami, Florida (US)",
  #   yul: "Montreal, Canada",
  #   bom: "Mumbai, India",
  #   cdg: "Paris, France",
  #   phx: "Phoenix, Arizona (US)",
  #   qro: "Querétaro, Mexico",
  #   gig: "Rio de Janeiro, Brazil",
  #   sjc: "San Jose, California (US)",
  #   scl: "Santiago, Chile",
  #   gru: "Sao Paulo, Brazil",
  #   sea: "Seattle, Washington (US)",
  #   ewr: "Secaucus, NJ (US)",
  #   sin: "Singapore, Singapore",
  #   arn: "Stockholm, Sweden",
  #   syd: "Sydney, Australia",
  #   nrt: "Tokyo, Japan",
  #   yyz: "Toronto, Canada",
  #   waw: "Warsaw, Poland",
  #   unknown: "your computer"
  # }


  @short %{
    ams: "Amsterdam",
    iad: "Ashburn",
    atl: "Atlanta" ,
    bog: "Bogotá",
    bos: "Boston",
    otp: "Bucharest",
    ord: "Chicago",
    dfw: "Dallas",
    den: "Denver",
    eze: "Ezeiza",
    fra: "Frankfurt",
    gdl: "Guadalajara",
    hkg: "Hong Kong",
    jnb: "Johannesburg",
    lhr: "London",
    lax: "Los Angeles",
    mad: "Madrid",
    mia: "Miami",
    yul: "Montreal",
    bom: "Mumbai",
    cdg: "Paris",
    phx: "Phoenix",
    qro: "Querétaro",
    gig: "Rio de Janeiro",
    sjc: "San Jose",
    scl: "Santiago",
    gru: "Sao Paulo",
    sea: "Seattle",
    ewr: "Secaucus",
    sin: "Singapore",
    arn: "Stockholm",
    syd: "Sydney",
    nrt: "Tokyo",
    yyz: "Toronto",
    waw: "Warsaw",
    unknown: "your computer"
  }

  def short(region_code) do
    # IO.inspect(region_code, label: "region_code")
    key = String.to_existing_atom(region_code)
    # IO.inspect(key, label: "key")
    # IO.inspect(@short, label: "short")
    # IO.inspect(@short[key], label: "short[key]")
    @short[key]
  end

end
