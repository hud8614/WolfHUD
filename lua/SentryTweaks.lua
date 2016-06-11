if RequiredScript == "lib/units/weapons/sentrygunweapon" then
	local old_setup = SentryGunWeapon.init
	local _switch_fire_original = SentryGunWeapon._switch_fire_mode
	local _setup_contour_original = SentryGunWeapon._setup_contour
	
	function SentryGunWeapon:init(...)
		old_setup(self, ...)
		managers.enemy:add_delayed_clbk("Sentry_post_init_" .. tostring(self._unit:key()), callback(self, self, "post_init"), Application:time() + 0.01)
	end
	
	function SentryGunWeapon:post_init()
		local enable_ap = false
		local laser_theme = ""
		if self._unit:base():get_owner_id() == managers.network:session():local_peer():id() then
			laser_theme = "player_sentry"
			enable_ap = managers.player:has_category_upgrade("sentry_gun", "ap_bullets")
		else
			laser_theme = "default_sentry"
		end
		self._laser_align = self._unit:get_object(Idstring("fire"))
		self:set_laser_enabled(laser_theme)
		
		if enable_ap then
			self:_switch_fire_mode()
			managers.network:session():send_to_peers_synched("sentrygun_sync_state", self._unit)
			local add_contour = self._use_armor_piercing and self._unit:base():ap_contour_id() or self._unit:base():standard_contour_id()
			self._unit:base():set_contour(add_contour)
		end
	end
end