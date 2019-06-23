require 'webdrivers'
require 'watir'
require 'open-uri'

#  main()
#                                                   
#  Runs off the main Pokédex page and gathers all the Pokémon and their sprites
#  @return  none
def main()
    browser = Watir::Browser.new #Watir Chrome Broswer
    url = "https://pokemondb.net/pokedex/national" # URL for all pokemon
    pokemonUrls = [] #The gathered list of pokemon to get sprites from

    browser.goto(url)
    links = browser.as()

    print "Gathering Pokemon . . . \n"

    links.each do |link|
        # Make sure to only grab the pokemon named links. Ignores other links on the Pokédex page as well as any empty links.
        if link.href.include?("pokedex") and !link.text.include?("Generation") and !link.text.include?("Pokémon") and !link.text.include?("Pokédex") and link.text != ""
            # Currently only grabs until gen 5. Change the name of the pokemon to change where it ends.
            # @todo create a smarter way to only grab to a certain generation
            if link.text.include?("Chespin")
                break
            end
            pokemonUrls << link.href
            print "Adding " + link.text + "\n"
        end
    end

    counter = 1
    pokemonUrls.each do |pokemonUrl|
        print "Visiting Pokemon " + counter.to_s + " of " + pokemonUrls.count.to_s + "\n"
        counter += 1
        getSprite(pokemonUrl)
    end
end

#  getSprite()
#                                                   
#  Downloads the sprite off the Pokémon's Pokédex entry
#  @param   url       =>  the url of the Pokémon's Pokédex entry
#  @return  none
def getSprite(url)
    browser.goto(url)
    # Change the version of the image to change the generation of the Pokémon sprite
    # @todo create a smarter way to determine generation wanted
    pokemonSprite = browser.element(class: "img-sprite-v13")
    pokemonName = pokemonSprite.attribute_value('alt').split(" ")[0]
    pokemonName = cleanName(pokemonName)
    spriteUrl = pokemonSprite.attribute_value('src')

    File.open(pokemonName + ".png", 'wb') do |file|
        file.write open(spriteUrl).read
    end
end

#  cleanName()
#                                                   
#  Cleans up the Pokémon's name to be used as a file name
#  @param   pokemonName       =>  the Pokémon's name
#  @return  the cleaned Pokémon name
def cleanName(pokemonName)
    # If statements are just for Nidoran to differentiate Female and Male before removing all non-alphanumeric characters
    if pokemonName.include?("♀")
        pokemonName.sub("♀", "F")
    end
    if pokemonName.include?("♂")
        pokemonName.sub("♂", "M")
    end
    pokemonName.gsub!(/\W/,'')
    return pokemonName
end

main()
