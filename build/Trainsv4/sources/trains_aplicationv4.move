module cuenta::trains_aplicationv4 {
    
    use std::debug::print;
    use aptos_std::table::{Self, Table};
    use std::string::{String, utf8};
    use std::signer::address_of;
    use std::option::{Self, Option, some, none};

    
    const YA_INICIALIZADO: u64 = 1;    
    const NO_INICIALIZADO: u64 = 2;    
    const REGISTRO_NO_EXISTE: u64 = 3;    
    const REGISTRO_YA_EXISTE: u64 = 4;   
    const NADA_A_MODIFICAR: u64 = 5;
    const MANTENIMIENTO: u64 = 6;

    struct Driver has store, copy, drop {        
        name: String,
        lastName: String,        
    }

    struct Route has store, copy, drop {
        
        start: Station,
        end: Station,        
        distans: u64,        
    }

    struct Station has store, copy, drop {
        
        name: String,
        local: String,        
        availability: bool,        
    }
    struct Train has store, copy, drop {
        
        model: String,
        color: String,        
        numCars: u64,
        driver: Option<Driver>,   
        route: Option<Route>,
        station: Station,
        availability:bool,
    }   

    struct FerroPaloma has key { // Dado a que utilizaremos este struct con operaciones del global_storage, necesita tener la habilidad key
        trains: Table<u64, Train>, // Declaramos tipo trenes
        stations: Table<u64, Station>,
        routes: Table<u64, Route>,
        drivers: Table<u64, Driver>        
    }

  
    public entry fun inicializar(cuenta: &signer) {
        assert!(!exists<FerroPaloma>(address_of(cuenta)), YA_INICIALIZADO); // En dado caso de que YA exista la Agenda, abortamos el proceso.
        move_to(cuenta, FerroPaloma {            
            trains: table::new<u64, Train>(), // Declaramos tipo trenes
            stations: table::new<u64, Station>(),
            routes: table::new<u64, Route>(),
            drivers: table::new<u64, Driver>(),  
        })
    }

    
    public entry fun set_station(
        
        cuenta: &signer, 
        id:u64,
        name: String,
        local: String,        
        availability: bool,
    ) acquires FerroPaloma {
        assert!(exists<FerroPaloma>(address_of(cuenta)), NO_INICIALIZADO); // Necesitamos que se haya corrido la funcion de inicializar primero.

        let registros = borrow_global_mut<FerroPaloma>(address_of(cuenta));
        assert!(!table::contains(&registros.stations, id), REGISTRO_YA_EXISTE);

        table::add(&mut registros.stations,
        id, 
        Station {
            name,
            local,        
            availability,
        });
    }

    #[view]
    public fun get_station(cuenta: address, id: u64): Station acquires FerroPaloma {
        assert!(exists<FerroPaloma>(cuenta), NO_INICIALIZADO);

        let registros = borrow_global<FerroPaloma>(cuenta);
        let resultado = table::borrow(&registros.stations, id);
        *resultado
    }

    #[view]
    public fun get_driver(cuenta: address, id: u64): Driver acquires FerroPaloma {
        assert!(exists<FerroPaloma>(cuenta), NO_INICIALIZADO);

        let registros = borrow_global<FerroPaloma>(cuenta);
        let resultado = table::borrow(&registros.drivers, id);
        *resultado
    }

    #[view]
    public fun get_route(cuenta: address, id: u64): Route acquires FerroPaloma {
        assert!(exists<FerroPaloma>(cuenta), NO_INICIALIZADO);

        let registros = borrow_global<FerroPaloma>(cuenta);
        let resultado = table::borrow(&registros.routes, id);
        *resultado
    }

    #[view]
    public fun get_train(cuenta: address, id: u64): Train acquires FerroPaloma {
        assert!(exists<FerroPaloma>(cuenta), NO_INICIALIZADO);

        let registros = borrow_global<FerroPaloma>(cuenta);
        let resultado = table::borrow(&registros.trains, id);
        *resultado
    }

    public entry fun set_driver(
        
        cuenta: &signer, 
        id: u64,
        name: String,
        lastName: String, 
    ) acquires FerroPaloma {
        assert!(exists<FerroPaloma>(address_of(cuenta)), NO_INICIALIZADO); // Necesitamos que se haya corrido la funcion de inicializar primero.

        let registros = borrow_global_mut<FerroPaloma>(address_of(cuenta));
        assert!(!table::contains(&registros.drivers, id), REGISTRO_YA_EXISTE);

        table::add(&mut registros.drivers,
        id, 
        Driver {
            name,
            lastName,
        });
    }

    public entry fun set_route(
        
        cuenta: &signer, 
        id: u64, 
        id_start: u64,
        id_end: u64,      
        distans: u64, 
    ) acquires FerroPaloma {
        assert!(exists<FerroPaloma>(address_of(cuenta)), NO_INICIALIZADO); // Necesitamos que se haya corrido la funcion de inicializar primero.

        let registros = borrow_global_mut<FerroPaloma>(address_of(cuenta));
        assert!(!table::contains(&registros.routes, id), REGISTRO_YA_EXISTE);

        assert!(table::contains(&registros.stations, id_start), REGISTRO_NO_EXISTE);
        assert!(table::contains(&registros.stations, id_end), REGISTRO_NO_EXISTE);

        let end = table::borrow(&registros.stations, id_end);
        let start = table::borrow(&registros.stations, id_start);
        
        table::add(&mut registros.routes,
        id, 
        Route {
            start: *start,
            end: *end,        
            distans,  
        });
    }

    public entry fun set_train(
        
        cuenta: &signer, 
        id: u64, 
        model: String,
        color: String,        
        numCars: u64,
        id_driver: u64,   
        id_route: u64,
        id_station: u64,
        availability:bool,

    ) acquires FerroPaloma {
        assert!(exists<FerroPaloma>(address_of(cuenta)), NO_INICIALIZADO); // Necesitamos que se haya corrido la funcion de inicializar primero.

        let registros = borrow_global_mut<FerroPaloma>(address_of(cuenta));
        assert!(!table::contains(&registros.trains, id), REGISTRO_YA_EXISTE);

        assert!(table::contains(&registros.stations, id_station), REGISTRO_NO_EXISTE);
        let regi_station = table::borrow(&registros.stations, id_station);

        if (availability) {
            assert!(table::contains(&registros.drivers, id_driver), REGISTRO_NO_EXISTE);
            assert!(table::contains(&registros.routes, id_route), REGISTRO_NO_EXISTE);

            let regi_driver = table::borrow(&registros.drivers, id_driver);
            let regi_route = table::borrow(&registros.routes, id_route);

            table::add(&mut registros.trains,
            id, 
            Train {            
                model,
                color,        
                numCars,
                driver: some(*regi_driver),   
                route: some(*regi_route),
                station: *regi_station,
                availability, 
            });

        } else { // No cerramos bloque.
            print(&utf8(b"No esta abilitado"));

            table::add(&mut registros.trains,
            id, 
            Train {            
                model,
                color,        
                numCars,
                driver: none(),   
                route: none(),
                station: *regi_station,
                availability, 
            });
        }; // Hasta aca se cierra.        
    }
        /*  Reglas de negocio  */

    public entry fun change_availability(
        
        cuenta: &signer, 
        id: u64,
        id_driver: u64,
        id_route: u64,        
        
    ) acquires FerroPaloma {
        assert!(exists<FerroPaloma>(address_of(cuenta)), NO_INICIALIZADO); // Necesitamos que se haya corrido la funcion de inicializar primero.
        
   
        let registros = borrow_global_mut<FerroPaloma>(address_of(cuenta));
        assert!(table::contains(&registros.trains, id), REGISTRO_YA_EXISTE);

        assert!(table::contains(&registros.drivers, id_driver), REGISTRO_NO_EXISTE);
        assert!(table::contains(&registros.routes, id_route), REGISTRO_NO_EXISTE);

        let regi_driver = table::borrow(&registros.drivers, id_driver);
        let regi_route = table::borrow(&registros.routes, id_route);

        let train_ref = &mut *table::borrow_mut(&mut registros.trains, id_route);
        let current_route = &mut train_ref.route;

        let train_ref_rout = &mut *table::borrow_mut(&mut registros.trains, id_driver);
        let current_driver = &mut train_ref_rout.driver;        

        let current_availability = &mut table::borrow_mut(&mut registros.trains, id).availability;
        //let current_driver = &mut table::borrow_mut(&mut registros.trains, id_driver).driver;
        //let current_route = &mut table::borrow_mut(&mut registros.trains, id_route).route;      
        

        if (*current_availability) {
            *current_availability = false;            

            *current_driver = none();
            *current_route = none();            

        } else { // No cerramos bloque.
            print(&utf8(b"Quueda habilitado"));

            *current_availability = true;
            *current_driver = some(*regi_driver);
            *current_route = some(*regi_route);

        }; // Hasta aca se cierra.      

        
    }  

}

