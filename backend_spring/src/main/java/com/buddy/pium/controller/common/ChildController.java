package com.buddy.pium.controller.common;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.common.ChildRequestDto;
import com.buddy.pium.dto.common.ChildResponseDto;
import com.buddy.pium.dto.common.ChildUpdateDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.common.ChildService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/child")
@RequiredArgsConstructor
public class ChildController {

    private final ChildService childService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createChild(
            @RequestPart("childData") String childDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            ChildRequestDto dto = mapper.readValue(childDataJson, ChildRequestDto.class);

            childService.addChild(dto, member, image);

            return ResponseEntity.ok(Map.of("message", "아이 등록이 완료되었습니다."));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{childId}")
    public ResponseEntity<?> deleteChild(@PathVariable Long childId,
                                         @CurrentMember Member member) {
        childService.deleteChild(childId, member);
        return ResponseEntity.ok(Map.of("message", "아이를 삭제했습니다."));
    }

    @PatchMapping(value = "/{childId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateChild(
            @PathVariable Long childId,
            @RequestPart("childData") String childDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            ChildUpdateDto dto = mapper.readValue(childDataJson, ChildUpdateDto.class);
            childService.updateChild(childId, dto, member, image);
            return ResponseEntity.ok(Map.of("message", "아이 정보를 수정했습니다."));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<List<ChildResponseDto>> getChildren(@CurrentMember Member member) {
        Long memberId = member.getId();
        Long mateId = member.getMateInfo(); // mateInfo가 null이면 null로 처리됨
        return ResponseEntity.ok(childService.getChildren(memberId, mateId));
    }
}
