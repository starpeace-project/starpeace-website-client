
EN_STRINGS = {
  'building.description.industry.label': 'Produces up to <%= output %>.'
  'building.description.industry.output.label': '<%= amount %> <%= unit %>/<%= duration %> of <%= resource %>'
  'building.description.industry.input.label': 'Requires <%= input %>.'
  'building.description.warehouse.label': 'Stores up to <%= storage %>.'
  'building.description.warehouse.output.label': '<%= amount %> <%= unit %> of <%= resource %>'


  'industry.category.none.label': 'None'
  'industry.category.civic.label': 'Civic'
  'industry.category.commerce.label': 'Commerce'
  'industry.category.industry.label': 'Industry'
  'industry.category.logistics.label': 'Logistics'
  'industry.category.real_estate.label': 'Real Estate'
  'industry.category.service.label': 'Service'

  'industry.type.appliance.label': 'Appliances'
  'industry.type.automobile.label': 'Automobile'
  'industry.type.banking.label': 'Banking'
  'industry.type.bar.label': 'Bars'
  'industry.type.book.label': 'Book'
  'industry.type.chemical.label': 'Chemical'
  'industry.type.clothes.label': 'Clothing'
  'industry.type.coal.label': 'Coal'
  'industry.type.college.label': 'College'
  'industry.type.compact_disc.label': 'Compact Disc'
  'industry.type.computer.label': 'Computer'
  'industry.type.computer_services.label': 'Computer Services'
  'industry.type.construction.label': 'Construction'
  'industry.type.crude_oil.label': 'Crude Oil'
  'industry.type.electronic_component.label': 'Electronic Component'
  'industry.type.fabric.label': 'Fabric'
  'industry.type.fast_food.label': 'Fast Food'
  'industry.type.farming.label': 'Farming'
  'industry.type.fire.label': 'Fire Safety'
  'industry.type.funeral_services.label': 'Funeral Services'
  'industry.type.furniture.label': 'Furniture'
  'industry.type.garbage.label': 'Garbage'
  'industry.type.gasoline.label': 'Gasoline'
  'industry.type.hospital.label': 'Hospital'
  'industry.type.headquarters.label': 'Headquarters'
  'industry.type.hc_residential.label': 'High-class Residential'
  'industry.type.lc_residential.label': 'Low-class Residential'
  'industry.type.legal_services.label': 'Legal Services'
  'industry.type.liquor.label': 'Liquor'
  'industry.type.machinery.label': 'Machinery'
  'industry.type.market.label': 'Market'
  'industry.type.mc_residential.label': 'Middle-class Residential'
  'industry.type.metal.label': 'Metallurgy'
  'industry.type.movie.label': 'Movie'
  'industry.type.museum.label': 'Museum'
  'industry.type.office.label': 'Office'
  'industry.type.ore.label': 'Ore'
  'industry.type.paper.label': 'Paper'
  'industry.type.park.label': 'Park'
  'industry.type.pharmaceutical.label': 'Pharmaceutical'
  'industry.type.plastic.label': 'Plastic'
  'industry.type.police.label': 'Police'
  'industry.type.prison.label': 'Prison'
  'industry.type.processed_food.label': 'Processed Food'
  'industry.type.raw_chemical.label': 'Raw Chemical'
  'industry.type.restaurant.label': 'Restaurant'
  'industry.type.school.label': 'School'
  'industry.type.silicon.label': 'Silicon'
  'industry.type.stone.label': 'Stone'
  'industry.type.television.label': 'Television'
  'industry.type.timber.label': 'Timber'
  'industry.type.toy.label': 'Toy'
  'industry.type.warehouse.label': 'Warehouse'

  'resource.type.appliance.label': 'appliances'
  'resource.type.automobile.label': 'automobiles'
  'resource.type.book.label': 'books'
  'resource.type.chemical.label': 'chemicals'
  'resource.type.clothes.label': 'clothing'
  'resource.type.coal.label': 'coal'
  'resource.type.compact_disc.label': 'compact discs'
  'resource.type.computer.label': 'computers'
  'resource.type.computer_services.label': 'computer services'
  'resource.type.construction.label': 'construction force'
  'resource.type.crude_oil.label': 'crude oil'
  'resource.type.electronic_component.label': 'electronic components'
  'resource.type.fabric.label': 'fabric'
  'resource.type.fresh_food.label': 'fresh food'
  'resource.type.furniture.label': 'furniture'
  'resource.type.gasoline.label': 'gasoline'
  'resource.type.legal_services.label': 'legal services'
  'resource.type.liquor.label': 'liquor'
  'resource.type.machinery.label': 'machinery'
  'resource.type.metal.label': 'metals'
  'resource.type.movie.label': 'movies'
  'resource.type.ore.label': 'ore'
  'resource.type.organic_material.label': 'organic material'
  'resource.type.paper.label': 'paper'
  'resource.type.printed_material.label': 'printed material'
  'resource.type.pharmaceutical.label': 'pharmaceuticals'
  'resource.type.plastic.label': 'plastic'
  'resource.type.processed_food.label': 'processed food'
  'resource.type.raw_chemical.label': 'raw chemicals'
  'resource.type.silicon.label': 'silicon'
  'resource.type.stone.label': 'stone'
  'resource.type.timber.label': 'timber'
  'resource.type.toy.label': 'toys'

  'resource.unit.cars.label': 'cars'
  'resource.unit.hours.label': 'hours'
  'resource.unit.items.label': 'items'
  'resource.unit.kilogram.label': 'kg'
  'resource.unit.liter.label': 'liters'
  'resource.unit.machines.label': 'machines'
  'resource.unit.meters.label': 'meters'
  'resource.unit.tons.label': 'tons'
}

export default class TranslationManager
  constructor: (@asset_manager, @ajax_state, @client_state, @options) ->
    @client_state.core.translations_library.load_translations_partial('EN', _.map(EN_STRINGS, (value, key) -> { id:key, value:value }))

  queue_asset_load: () ->
    current_language = @options.language()
    return if @client_state.core.translations_library.has_metadata(current_language) || @ajax_state.is_locked('assets.translations', current_language)

    @ajax_state.lock('assets.translations', current_language)
    @asset_manager.queue("translations.#{current_language.toLowerCase()}", "./translations.#{current_language.toLowerCase()}.json", (resource) =>
      @client_state.core.translations_library.load_translations(current_language, resource.data.translations)
      @ajax_state.unlock('assets.translations', current_language)
    )

  text: (key) ->
    @client_state.core.translations_library.translations_by_language_code[@options.language()]?[key]
