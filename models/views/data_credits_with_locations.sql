SELECT dc.time AS time, 
		dc.owner, dc.client, dc.location, 
		dc.dcs, dc.packets, 
		Locations.long_street, Locations.short_street, Locations.long_city, Locations.short_city, Locations.long_state, Locations.short_state, Locations.long_country, Locations.short_country, Locations.search_city, Locations.city_id, Locations.geometry,
	--   ST_AsGeoJSON(geometry)::json->'coordinates'->>1 as lat, ST_AsGeoJSON(geometry)::json->'coordinates'->>0 as long
		ST_Y(geometry)::double precision as lat, ST_X(geometry)::double precision as long
	FROM {{ ref('data_credits') }} dc
	LEFT JOIN {{ source('etl', 'locations') }} Locations ON dc.location = Locations.location
	WHERE Locations.geometry IS NOT NULL