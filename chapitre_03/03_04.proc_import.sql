create or replace procedure import.import_concentration_france ()
language plpgsql    
as $$
begin
	-- insertion d'éventuels nouveaux types de mesures
	insert into polluants.type_de_mesure
		(type_evaluation,
		procedure_de_mesure,
		type_de_valeur)
	select distinct 
		i.type_evaluation,
		i.procedure_de_mesure,
		i.type_de_valeur
	from import.concentration_france i
	left join polluants.type_de_mesure tm
		on  i.type_evaluation     = tm.type_evaluation
		and i.procedure_de_mesure = tm.procedure_de_mesure
		and i.type_de_valeur      = tm.type_de_valeur
	where tm.type_de_mesure_id is null;
	
	-- insertion d'éventuels nouveaux sites
	merge into polluants.site as cible
	using (SELECT DISTINCT
			code_site,
			MIN(nom_site) AS nom_site,
			MIN(organisme) AS organisme,
			MIN(type_implantation) AS type_implantation,
			MIN(code_zas) AS code_zas,
			MIN(zas) AS zas
		FROM import.concentration_france
		GROUP BY code_site
    ) as source
	on cible.code_site = source.code_site
	when matched then
	    update set
	        site = source.nom_site,
	        organisme = source.organisme,
	        type_implantation = source.type_implantation,
	        code_zas = source.code_zas,
	        zas = source.zas
	when not matched then
	    insert (code_site, site, organisme, type_implantation, code_zas, zas)
	    values (source.code_site, source.nom_site, source.organisme, source.type_implantation, source.code_zas, source.zas);
	
	-- insertion dans la table finale
	insert into polluants.concentration_france
	(
		date_debut, 
		date_fin, 
		code_site, 
		polluant, 
		type_influence, 
		discriminant, 
		reglementaire, 
		type_de_mesure_id, 
		valeur, 
		valeur_brute, 
		unite_de_mesure, 
		taux_de_saisie, 
		couverture_temporelle, 
		couverture_de_donnees, 
		code_qualite, 
		validite)
	select 
		cast(i.date_debut as timestamp(0)) as date_debut, 
		cast(i.date_fin as timestamp(0)) as date_fin,
		i.code_site, 
		i.polluant, 
		i.type_influence, 
		i.discriminant, 
		i.reglementaire, 
		tm.type_de_mesure_id, 
		i.valeur, 
		i.valeur_brute, 
		i.unite_de_mesure, 
		i.taux_de_saisie, 
		i.couverture_temporelle, 
		i.couverture_de_donnees, 
		i.code_qualite, 
		i.validite
	from import.concentration_france i
	join polluants.type_de_mesure tm
		on  i.type_evaluation     = tm.type_evaluation
		and i.procedure_de_mesure = tm.procedure_de_mesure
		and i.type_de_valeur      = tm.type_de_valeur;

	delete from import.concentration_france;
end;$$;